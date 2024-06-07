import { Then } from '@cucumber/cucumber';
import { waitFor, waitForResult, waitForSelector } from './support/wait-for-behavior';
import { getElementPath } from './support/web-element-helper';
import { ScenarioWorld } from './setup/world';
import { ElementKey } from '../env/globals';
import { inputElementValue, selectElementValue } from './support/html-behavior';

Then(
  /^I fill in the "([^"]*)" input with "([^"]*)"$/,
  async function(this: ScenarioWorld, elementsKey: ElementKey, input: string) {
    const {
      screen: { page },
      globalConfig

    } = this;

    const elementPath = getElementPath(page, elementsKey, globalConfig);

    await waitFor(async () => {
      const result = await page.waitForSelector(elementPath, {
        state: 'visible'
      });

      if (result) {
        await inputElementValue(page, elementPath, input);
      }
      return result;
    });

  }
);

Then(
  /^I select the "([^"]*)" "([^"]*)" from the "([^"]*)"$/,
  async function(this: ScenarioWorld, option: string, selection: ElementKey, elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig
    } = this;


    const elementPath = getElementPath(page, elementKey, globalConfig);
    const selectionPath = getElementPath(page, selection, globalConfig);

    await waitFor(async () => {
        const elementStable = await waitForSelector(page, elementPath);

        if (elementStable) {
          await selectElementValue(page, selectionPath, elementPath, option);
          return waitForResult.PASS;
        }

        return waitForResult.ELEMENT_NOT_AVAILABLE;
      }
      //     globalConfig,
      //     { target: elementKey })
      // }
    );
  });
