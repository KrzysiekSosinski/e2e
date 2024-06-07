import { Page } from 'playwright';
import { ElementKey, ElementLocator, GlobalConfig } from '../../env/globals';
import { getCurrentPageId } from './navigation-behaviour';

export const getElementPath = (

  page: Page,
  elementKey: ElementKey,
  globalConfig: GlobalConfig

): ElementLocator => {

  const { pageElementMappings } = globalConfig;
  const currentPage = getCurrentPageId(page, globalConfig);
  return pageElementMappings[currentPage]?.[elementKey] || pageElementMappings.common?.[elementKey]

};

