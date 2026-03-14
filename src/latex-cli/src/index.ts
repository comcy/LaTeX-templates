import { Command } from 'commander';
import * as fs from 'fs-extra';
import * as path from 'path';
import * as yaml from 'js-yaml';
import inquirer from 'inquirer';
import chalk from 'chalk';
import { execSync, spawn } from 'child_process';
import os from 'os';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const program = new Command();
const CONFIG_DIR = path.join(os.homedir(), '.latex-cli');
const CONFIG_FILE = path.join(CONFIG_DIR, 'config.yaml');
// Adjusted for dist/index.js location
const TEMPLATES_DIR = path.join(__dirname, '..', 'templates');

interface Config {
  person: {
    name: string;
    street: string;
    city: string;
    phone: string;
    email: string;
  };
  defaults: {
    editor: string;
    engine: string;
    viewer: string;
    build: boolean;
  };
}

async function ensureConfig() {
  if (!fs.default.existsSync(CONFIG_FILE)) {
    console.log(chalk.yellow('No configuration found. Please run "init" first.'));
    process.exit(1);
  }
  return yaml.load(fs.default.readFileSync(CONFIG_FILE, 'utf8')) as Config;
}

program
  .name('latex-cli')
  .description('CLI for generating LaTeX documents from templates')
  .version('1.0.0');

program
  .command('init')
  .description('Initialize local configuration')
  .action(async () => {
    const questions = [
      { type: 'input', name: 'name', message: 'Name:' },
      { type: 'input', name: 'street', message: 'Street:' },
      { type: 'input', name: 'city', message: 'City (ZIP + City):' },
      { type: 'input', name: 'phone', message: 'Phone:' },
      { type: 'input', name: 'email', message: 'Email:' },
      { type: 'input', name: 'editor', message: 'Editor:', default: 'nano' },
      { type: 'input', name: 'engine', message: 'LaTeX Engine (e.g., pdflatex, xelatex):', default: 'pdflatex' },
      { type: 'input', name: 'viewer', message: 'PDF Viewer (e.g., xdg-open, open):', default: 'xdg-open' },
    ];

    const answers = await (inquirer.prompt as any)(questions);
    const config: Config = {
      person: {
        name: answers.name,
        street: answers.street,
        city: answers.city,
        phone: answers.phone,
        email: answers.email,
      },
      defaults: {
        editor: answers.editor,
        engine: answers.engine,
        viewer: answers.viewer,
        build: true,
      },
    };

    fs.default.ensureDirSync(CONFIG_DIR);
    fs.default.writeFileSync(CONFIG_FILE, yaml.dump(config));
    console.log(chalk.green(`Configuration saved to ${CONFIG_FILE}`));
  });

program
  .command('templates')
  .description('List available templates')
  .action(() => {
    if (!fs.default.existsSync(TEMPLATES_DIR)) {
      console.error(chalk.red(`Templates directory not found at ${TEMPLATES_DIR}`));
      process.exit(1);
    }
    const templates = fs.default.readdirSync(TEMPLATES_DIR).filter(f => fs.default.statSync(path.join(TEMPLATES_DIR, f)).isDirectory());
    console.log(chalk.blue('Available Templates:'));
    templates.forEach(t => console.log(`- ${t}`));
  });

program
  .command('new <type> [name]')
  .description('Create a new document from a template')
  .action(async (type, name) => {
    const config = await ensureConfig();
    const templatePath = path.join(TEMPLATES_DIR, type, `${type}.tex`);
    const makefileTemplatePath = path.join(TEMPLATES_DIR, type, 'Makefile');

    if (!fs.default.existsSync(templatePath)) {
      console.error(chalk.red(`Template "${type}" not found.`));
      process.exit(1);
    }

    const { rec_prefix, rec_name, rec_street, rec_city, subject } = await (inquirer.prompt as any)([
      { type: 'input', name: 'rec_prefix', message: 'Recipient Prefix (Optional, e.g. Company):' },
      { type: 'input', name: 'rec_name', message: 'Recipient Name:' },
      { type: 'input', name: 'rec_street', message: 'Recipient Street:' },
      { type: 'input', name: 'rec_city', message: 'Recipient City:' },
      { type: 'input', name: 'subject', message: 'Subject:' },
    ]);

    let targetDir: string;
    if (name) {
      targetDir = name;
    } else {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 16);
      targetDir = `document_${type}_${timestamp}`;
    }

    if (fs.default.existsSync(targetDir)) {
      console.error(chalk.red(`Error: Directory "${targetDir}" already exists.`));
      process.exit(1);
    }

    const targetFile = path.join(targetDir, `${type}.tex`);
    const targetMakefile = path.join(targetDir, 'Makefile');

    fs.default.ensureDirSync(targetDir);
    let content = fs.default.readFileSync(templatePath, 'utf8');

    // Handle optional prefix
    const prefixValue = rec_prefix ? `${rec_prefix}\\\\` : '';

    // Replacement mapping
    const replacements: Record<string, string> = {
      '<<NAME>>': config.person.name,
      '<<STREET>>': config.person.street,
      '<<CITY>>': config.person.city,
      '<<PHONE>>': config.person.phone,
      '<<EMAIL>>': config.person.email,
      '<<BETREFF>>': subject,
      '<<RECEIVER_PREFIX>>': prefixValue,
      '<<RECEIVER_NAME>>': rec_name,
      '<<RECEIVER_STREET>>': rec_street,
      '<<RECEIVER_CITY>>': rec_city,
      '<<TEXT>>': '[WRITE CONTENT HERE]',
    };

    for (const [key, value] of Object.entries(replacements)) {
      content = content.split(key).join(value);
    }

    fs.default.writeFileSync(targetFile, content);

    // Makefile handling
    if (fs.default.existsSync(makefileTemplatePath)) {
      let makefileContent = fs.default.readFileSync(makefileTemplatePath, 'utf8');
      makefileContent = makefileContent.split('<<ENGINE>>').join(config.defaults.engine || 'pdflatex');
      makefileContent = makefileContent.split('<<TYPE>>').join(type);
      fs.default.writeFileSync(targetMakefile, makefileContent);
    }

    console.log(chalk.green(`Successfully created new ${type} in ${targetDir}`));

    // Open editor
    try {
      execSync(`${config.defaults.editor} ${targetFile}`, { stdio: 'inherit' });
    } catch (e) {
      console.warn(chalk.yellow(`Could not open editor: ${config.defaults.editor}`));
    }

    // Post-Editor Build and View
    const { doBuild } = await (inquirer.prompt as any)([
      { type: 'confirm', name: 'doBuild', message: `Build PDF and open with ${config.defaults.viewer || 'viewer'}?`, default: true }
    ]);

    if (doBuild) {
      console.log(chalk.blue('Building PDF...'));
      try {
        execSync('make', { cwd: targetDir, stdio: 'inherit' });
        const pdfFile = path.join(targetDir, `${type}.pdf`);
        if (fs.default.existsSync(pdfFile)) {
          console.log(chalk.green('Opening PDF...'));
          spawn(config.defaults.viewer || 'xdg-open', [pdfFile], {
            detached: true,
            stdio: 'ignore'
          }).unref();
        } else {
          console.error(chalk.red('Error: PDF build failed (file not found).'));
        }
      } catch (e) {
        console.error(chalk.red('Error: PDF build failed (make error).'));
      }
    }
  });

program.parse(process.argv);
