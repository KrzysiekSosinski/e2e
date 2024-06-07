import { ElementLocator } from '../../env/globals';
import { Page } from 'playwright';
import { envNumber } from '../../env/parseEnv';

export const enum waitForResult {
  PASS = 1,
  FAIL = 2,
  ELEMENT_NOT_AVAILABLE=3
}

export const waitFor = async <T>(
  predicate: () => T | Promise<T>,
  options?: { timeout?: number; wait?: number }
): Promise<T> => {
  const { timeout = 30000, wait = 2000 } = options || {};

  const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
  const startDate = new Date();

  while (new Date().getTime() - startDate.getTime() < timeout) {
    const result = await predicate();

    if (result) return result;

    await sleep(wait);
    console.log(`Waiting... ${wait}ms`);

  }

  throw new Error(`Wait time of ${timeout}ms exceeded`);
};

export const waitForSelector = async (
  page: Page,
  elementIdentifier: ElementLocator
): Promise<boolean> => {
  try {
    await page.waitForSelector(elementIdentifier, {
      state: 'visible',
      timeout: envNumber('SELECTOR_TIMEOUT')
    })
    return true
  } catch (e) {
    return false
  }
}
