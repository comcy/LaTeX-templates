import { Command } from 'commander';
import fs from 'fs-extra';
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
const TEMPLATES_DIR = path.join(__dirname, '..', 'templates');

interface Author {
  name: string;
  email: string;
  department?: string;
}

interface Config {
  person: {
    name: string;
    street: string;
    city: string;
    phone: string;
    email: string;
    business_email: string;
  };
  article?: {
    main_author: Author;
    co_authors: Author[];
  };
  defaults: {
    editor: string;
    engine: string;
    viewer: string;
    build: boolean;
  };
}

async function loadConfig(): Promise<Config | null> {
  if (!fs.existsSync(CONFIG_FILE)) return null;
  return yaml.load(fs.readFileSync(CONFIG_FILE, 'utf8')) as Config;
}

async function saveConfig(config: Config) {
  fs.ensureDirSync(CONFIG_DIR);
  fs.writeFileSync(CONFIG_FILE, yaml.dump(config));
}

program
  .name('latex-cli')
  .description('CLI for generating LaTeX documents from templates')
  .version('1.1.0');

const init = program.command('init').description('Initialize local configuration');

init
  .command('letter')
  .description('Initialize personal data for letters')
  .action(async () => {
    const existing = await loadConfig();
    const questions = [
      { type: 'input', name: 'name', message: 'Name:', default: existing?.person?.name },
      { type: 'input', name: 'street', message: 'Street:', default: existing?.person?.street },
      { type: 'input', name: 'city', message: 'City (ZIP + City):', default: existing?.person?.city },
      { type: 'input', name: 'phone', message: 'Phone:', default: existing?.person?.phone },
      { type: 'input', name: 'email', message: 'Private Email:', default: existing?.person?.email },
      { type: 'input', name: 'business_email', message: 'Business Email:', default: existing?.person?.business_email },
      { type: 'input', name: 'editor', message: 'Editor:', default: existing?.defaults?.editor || 'nano' },
      { type: 'input', name: 'engine', message: 'LaTeX Engine:', default: existing?.defaults?.engine || 'pdflatex' },
      { type: 'input', name: 'viewer', message: 'PDF Viewer:', default: existing?.defaults?.viewer || 'xdg-open' },
    ];

    const answers = await (inquirer.prompt as any)(questions);
    const config: Config = {
      ...(existing || {}),
      person: {
        name: answers.name,
        street: answers.street,
        city: answers.city,
        phone: answers.phone,
        email: answers.email,
        business_email: answers.business_email,
      },
      defaults: {
        editor: answers.editor,
        engine: answers.engine,
        viewer: answers.viewer,
        build: true,
      } as any
    };
    await saveConfig(config);
    console.log(chalk.green('Letter configuration saved.'));
  });

init
  .command('article')
  .description('Initialize author data for articles')
  .action(async () => {
    const existing = await loadConfig();
    console.log(chalk.blue('Main Author Details:'));
    const mainAuthor = await (inquirer.prompt as any)([
      { type: 'input', name: 'name', message: 'Name:', default: existing?.article?.main_author?.name || existing?.person?.name },
      { type: 'input', name: 'email', message: 'Email:', default: existing?.article?.main_author?.email || existing?.person?.business_email },
      { type: 'input', name: 'department', message: 'Department (Optional):', default: existing?.article?.main_author?.department },
    ]);

    const coAuthors: Author[] = [];
    let addMore = true;
    while (addMore) {
      const { confirm } = await (inquirer.prompt as any)({
        type: 'confirm',
        name: 'confirm',
        message: 'Add a persistent Co-Author to config?',
        default: false,
      });
      if (!confirm) break;

      const coAuthor = await (inquirer.prompt as any)([
        { type: 'input', name: 'name', message: 'Co-Author Name:' },
        { type: 'input', name: 'email', message: 'Co-Author Email:' },
        { type: 'input', name: 'department', message: 'Co-Author Department (Optional):' },
      ]);
      coAuthors.push(coAuthor);
    }

    const config: Config = {
      ...(existing || { person: {} as any, defaults: {} as any }),
      article: {
        main_author: mainAuthor,
        co_authors: coAuthors,
      }
    };
    await saveConfig(config);
    console.log(chalk.green('Article configuration saved.'));
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
  .command('new <type> [name]')
  .description('Create a new document from a template')
  .action(async (type, name) => {
    const config = await loadConfig();
    if (!config) {
      console.log(chalk.yellow(`No configuration found. Please run "latex-cli init ${type}" first.`));
      process.exit(1);
    }

    const templateDir = path.join(TEMPLATES_DIR, type);
    if (!fs.existsSync(templateDir)) {
      console.error(chalk.red(`Template "${type}" not found.`));
      process.exit(1);
    }

    let replacements: Record<string, string> = {
      '<<NAME>>': config.person?.name || '',
      '<<STREET>>': config.person?.street || '',
      '<<CITY>>': config.person?.city || '',
      '<<PHONE>>': config.person?.phone || '',
      '<<EMAIL>>': config.person?.email || '',
      '<<BUSINESS_EMAIL>>': config.person?.business_email || '',
      '<<TEXT>>': '[WRITE CONTENT HERE]',
    };

    if (type === 'letter') {
      const answers = await (inquirer.prompt as any)([
        { type: 'input', name: 'rec_prefix', message: 'Recipient Prefix (Optional):' },
        { type: 'input', name: 'rec_name', message: 'Recipient Name:' },
        { type: 'input', name: 'rec_street', message: 'Recipient Street:' },
        { type: 'input', name: 'rec_city', message: 'Recipient City:' },
        { type: 'input', name: 'subject', message: 'Subject:' },
      ]);
      replacements['<<RECEIVER_PREFIX>>'] = answers.rec_prefix ? `${answers.rec_prefix}\\\\` : '';
      replacements['<<RECEIVER_NAME>>'] = answers.rec_name;
      replacements['<<RECEIVER_STREET>>'] = answers.rec_street;
      replacements['<<RECEIVER_CITY>>'] = answers.rec_city;
      replacements['<<BETREFF>>'] = answers.subject;
    } else if (type === 'article') {
      const { subject } = await (inquirer.prompt as any)({ type: 'input', name: 'subject', message: 'Article Title:' });
      replacements['<<BETREFF>>'] = subject;

      const authors: Author[] = [];
      if (config.article) {
        authors.push(config.article.main_author);
        authors.push(...config.article.co_authors);
      }

      let addExtra = true;
      while (addExtra) {
        const { confirm } = await (inquirer.prompt as any)({ type: 'confirm', name: 'confirm', message: 'Add an extra Co-Author for THIS article?', default: false });
        if (!confirm) break;
        const extra = await (inquirer.prompt as any)([
          { type: 'input', name: 'name', message: 'Name:' },
          { type: 'input', name: 'email', message: 'Email:' },
          { type: 'input', name: 'department', message: 'Department (Optional):' },
        ]);
        authors.push(extra);
      }

      // Format LaTeX Author Block
      let authorBlock = "";
      let affiliationBlock = "";
      authors.forEach((auth, index) => {
        const i = index + 1;
        authorBlock += `${auth.name}\\textsuperscript{${i}}`;
        authorBlock += `\\\\{\\small \\href{mailto:${auth.email}}{(${auth.email})}}`;
        if (index < authors.length - 1) authorBlock += " \\and ";
        
        if (auth.department) {
          affiliationBlock += `\\textsuperscript{${i}}${auth.department}\\\\`;
        }
      });
      replacements['<<AUTHORS>>'] = authorBlock;
      replacements['<<AFFILIATIONS>>'] = affiliationBlock;
    } else {
      const { subject } = await (inquirer.prompt as any)({ type: 'input', name: 'subject', message: 'Subject:' });
      replacements['<<BETREFF>>'] = subject;
    }

    const targetDir = name || `document_${type}_${new Date().toISOString().replace(/[:.]/g, '-').slice(0, 16)}`;
    if (fs.existsSync(targetDir)) {
      console.error(chalk.red(`Error: Directory "${targetDir}" already exists.`));
      process.exit(1);
    }

    // Ensure target exists and copy EVERYTHING from template folder
    fs.ensureDirSync(targetDir);
    console.log(chalk.blue(`Copying template from ${templateDir} to ${targetDir}...`));
    fs.copySync(templateDir, targetDir);

    const targetFile = path.join(targetDir, `${type}.tex`);
    if (fs.existsSync(targetFile)) {
      let texContent = fs.readFileSync(targetFile, 'utf8');
      for (const [key, value] of Object.entries(replacements)) {
        texContent = texContent.split(key).join(value || '');
      }
      fs.writeFileSync(targetFile, texContent);
    }

    const targetMakefile = path.join(targetDir, 'Makefile');
    if (fs.existsSync(targetMakefile)) {
      let makefileContent = fs.readFileSync(targetMakefile, 'utf8');
      makefileContent = makefileContent.split('<<ENGINE>>').join(config.defaults.engine || 'pdflatex');
      makefileContent = makefileContent.split('<<TYPE>>').join(type);
      fs.writeFileSync(targetMakefile, makefileContent);
    }

    console.log(chalk.green(`Created new ${type} in ${targetDir}`));
    try {
      execSync(`${config.defaults.editor} ${targetFile}`, { stdio: 'inherit' });
    } catch (e) {}

    const { doBuild } = await (inquirer.prompt as any)({ type: 'confirm', name: 'doBuild', message: `Build PDF and open with ${config.defaults.viewer}?`, default: true });
    if (doBuild) {
      try {
        execSync('make', { cwd: targetDir, stdio: 'inherit' });
        const pdfFile = path.join(targetDir, `${type}.pdf`);
        if (fs.existsSync(pdfFile)) {
          spawn(config.defaults.viewer, [pdfFile], { detached: true, stdio: 'ignore' }).unref();
        }
      } catch (e) {}
    }
  });

program.parse(process.argv);
