import { Then } from '@cucumber/cucumber';
import { waitFor } from '../support/wait-for-behavior';
import { ScenarioWorld } from '../setup/world';
import { getElementPath } from '../support/web-element-helper';
import { ElementKey } from '../../env/globals';


Then(
  /^"([^"]*)" radiobutton should be checked/,
  async function(this: ScenarioWorld, elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig
    } = this;

    console.log(`the ${elementKey} radiobutton should be checked`)

    const pathToElement = getElementPath(page, elementKey, globalConfig)

    await waitFor(async () => {
      return await page.isChecked(pathToElement);
    });
  }
);
