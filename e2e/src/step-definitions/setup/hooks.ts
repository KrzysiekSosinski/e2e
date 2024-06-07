import { After, Before, setDefaultTimeout } from '@cucumber/cucumber';
import { ScenarioWorld } from './world';
import { env, envNumber } from '../../env/parseEnv';

setDefaultTimeout(envNumber('SCRIPT_TIMEOUT'));

Before(async function(this: ScenarioWorld) {

  return await this.init();

});

After(async function(this: ScenarioWorld, scenario) {
  const scenarioStatus = scenario.result?.status;
  const { screen: { page, browser } } = this;
  const dateTime = new Date().toISOString().replace(/:/g, '-').replace(/\..+/, '');

  if (scenarioStatus === 'FAILED') {
    await new Promise(f => setTimeout(f, 500));
    const screenshot = await page.screenshot({
      path: `${env('SCREENSHOT_PATH')}${scenario.pickle.name}${dateTime}.png`
    });
    await this.attach(screenshot, 'image/png');
  }
  await browser.close();
  return browser;
});
