import { When } from '@cucumber/cucumber';
import {
  clickElement
} from './support/html-behavior';
import { ScenarioWorld } from './setup/world';
import { waitFor } from './support/wait-for-behavior';
import { getElementPath } from './support/web-element-helper';
import { ElementKey } from '../env/globals';

When(
  /^I click the "([^"]*)" (?:button|link)(?: with parameter "([^"]*)")?$/,
  async function(this: ScenarioWorld, elementKey: ElementKey, parameter?: string) {
    const {
      screen: { page },
      globalConfig
    } = this;

    let elementIdentifier: string;

    if (parameter) {
      elementIdentifier = getElementPath(page, elementKey, globalConfig);
      elementIdentifier = elementIdentifier.replace('{{value}}', parameter)

    } else {
      elementIdentifier = getElementPath(page, elementKey, globalConfig);
    }


    await waitFor(async () => {
      const result = await page.waitForSelector(elementIdentifier, {
        state: 'visible'
      });
      if (result) {
        await clickElement(page, elementIdentifier);
      }
      return result;
    });
  }
);
