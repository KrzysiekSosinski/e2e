import { ScenarioWorld } from './setup/world';
import { ElementKey } from '../env/globals';
import { waitFor, waitForResult, waitForSelector } from './support/wait-for-behavior';
import { getElementPath } from './support/web-element-helper';
import { checkElement, uncheckElement } from './support/html-behavior';
import { Then } from '@cucumber/cucumber';

Then(
  /^I (check)?(uncheck)? the "([^"]*)" (?:check box|radio button)$/,
  async function(this: ScenarioWorld, checked: boolean, unchecked: boolean, elementKey: ElementKey) {
    const {
      screen: { page },
      globalConfig
    } = this;

    const elementIdentifier = getElementPath(page, elementKey, globalConfig);

    await waitFor(async () => {
        const elementStable = await waitForSelector(page, elementIdentifier);

        if (elementStable) {
          if (!!unchecked) {
            await uncheckElement(page, elementIdentifier);
            return waitForResult.PASS;
          } else {
            await checkElement(page, elementIdentifier);
            return waitForResult.PASS;
          }
        }
        return waitForResult.ELEMENT_NOT_AVAILABLE;
      }
      //     globalConfig,
      //     { target: elementKey })
      // }
    );
  });
