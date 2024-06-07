import reporter, { Options } from 'cucumber-html-reporter'
import dotenv from 'dotenv'
import { env } from '../env/parseEnv'

import path from 'path';

dotenv.config({ path: env('COMMON_CONFIG_FILE') });

const dateTime = new Date().toISOString().replace(/:/g, '-').replace(/\..+/, '');
const reportsBaseDir = process.env.REPORTS_BASE_DIR || './reports';

const htmlFileName = `report_${dateTime}.html`;
const htmlFilePath = path.join(reportsBaseDir, htmlFileName);

const options: Options = {
  theme: 'bootstrap',
  jsonFile: process.env.JSON_REPORT_FILE,
  output: htmlFilePath,
  screenshotsDirectory: process.env.SCREENSHOT_PATH || 'screenshots',
  reportSuiteAsScenarios: true,
  launchReport: false,
};

reporter.generate(options)
