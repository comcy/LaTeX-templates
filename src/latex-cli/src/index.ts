import { Command } from 'commander';
import * as fs from 'fs-extra';
import * as path from 'path';
import * as yaml from 'js-yaml';
import inquirer from 'inquirer';
import chalk from 'chalk';
import { execSync } from 'child_process';
import os from 'os';

const program = new Command();
const CONFIG_DIR = path.join(os.homedir(), '.latex-cli');
const CONFIG_FILE = path.join(CONFIG_DIR, 'config.yaml');
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
    build: boolean;
  };
}

async function ensureConfig() {
  if (!fs.existsSync(CONFIG_FILE)) {
    console.log(chalk.yellow('No configuration found. Please run "init" first.'));
    process.exit(1);
  }
  return yaml.load(fs.readFileSync(CONFIG_FILE, 'utf8')) as Config;
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
      { name: 'name', message: 'Name:' },
      { name: 'street', message: 'Street:' },
      { name: 'city', message: 'City (ZIP + City):' },
      { name: 'phone', message: 'Phone:' },
      { name: 'email', message: 'Email:' },
      { name: 'editor', message: 'Editor:', default: 'nano' },
      { name: 'engine', message: 'LaTeX Engine (e.g., pdflatex, xelatex):', default: 'pdflatex' },
    ];

    const answers = await inquirer.prompt(questions);
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
        build: true,
      },
    };

    fs.ensureDirSync(CONFIG_DIR);
    fs.writeFileSync(CONFIG_FILE, yaml.dump(config));
    console.log(chalk.green(`Configuration saved to ${CONFIG_FILE}`));
  });

program
  .command('templates')
  .description('List available templates')
  .action(() => {
    const templates = fs.readdirSync(TEMPLATES_DIR).filter(f => fs.statSync(path.join(TEMPLATES_DIR, f)).isDirectory());
    console.log(chalk.blue('Available Templates:'));
    templates.forEach(t => console.log(`- ${t}`));
  });

program
  .command('new <type>')
  .description('Create a new document from a template')
  .action(async (type) => {
    const config = await ensureConfig();
    const templatePath = path.join(TEMPLATES_DIR, type, `${type}.tex`);
    const makefileTemplatePath = path.join(TEMPLATES_DIR, type, 'Makefile');

    if (!fs.existsSync(templatePath)) {
      console.error(chalk.red(`Template "${type}" not found.`));
      process.exit(1);
    }

    const { subject, recipient } = await inquirer.prompt([
      { name: 'subject', message: 'Subject:' },
      {
        name: 'recipient',
        type: 'editor',
        message: 'Enter recipient (use multiple lines):',
      },
    ]);

    // Format recipient for LaTeX
    const formattedRecipient = recipient.trim().replace(/\n/g, '\\\\\n');

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 16);
    const targetDir = `document_${type}_${timestamp}`;
    const targetFile = path.join(targetDir, `${type}.tex`);
    const targetMakefile = path.join(targetDir, 'Makefile');

    fs.ensureDirSync(targetDir);
    let content = fs.readFileSync(templatePath, 'utf8');

    // Replacement mapping
    const replacements: Record<string, string> = {
      '<<NAME>>': config.person.name,
      '<<STREET>>': config.person.street,
      '<<CITY>>': config.person.city,
      '<<PHONE>>': config.person.phone,
      '<<EMAIL>>': config.person.email,
      '<<BETREFF>>': subject,
      '<<EMPFAENGER>>': formattedRecipient,
      '<<TEXT>>': '[WRITE CONTENT HERE]',
    };

    for (const [key, value] of Object.entries(replacements)) {
      content = content.split(key).join(value);
    }

    fs.writeFileSync(targetFile, content);

    // Makefile handling
    if (fs.existsSync(makefileTemplatePath)) {
      let makefileContent = fs.readFileSync(makefileTemplatePath, 'utf8');
      makefileContent = makefileContent.split('<<ENGINE>>').join(config.defaults.engine || 'pdflatex');
      makefileContent = makefileContent.split('<<TYPE>>').join(type);
      fs.writeFileSync(targetMakefile, makefileContent);
    }

    console.log(chalk.green(`Successfully created new ${type} in ${targetDir}`));

    // Open editor
    try {
      execSync(`${config.defaults.editor} ${targetFile}`, { stdio: 'inherit' });
    } catch (e) {
      console.warn(chalk.yellow(`Could not open editor: ${config.defaults.editor}`));
    }
  });

program.parse(process.argv);
