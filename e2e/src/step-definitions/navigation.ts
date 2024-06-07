import { Given } from '@cucumber/cucumber';
import { PageId } from '../env/globals';
import { navigateToPage } from './support/navigation-behaviour';
import { ScenarioWorld } from  './setup/world'

Given(
  /^I am on the "([^"]*)" page$/,
  async function(this: ScenarioWorld, pageId: PageId) {

    const {

      screen: { page },
      globalConfig,
      globalVariables,

    } = this;

    globalVariables.currentScreen = pageId;

    await navigateToPage(page, pageId, globalConfig);
  }
);
