import { DataTable } from '@cucumber/cucumber';
import { Then } from '@cucumber/cucumber';
import { getElementPath } from '../support/web-element-helper';
import { ScenarioWorld } from '../setup/world';
import { ElementKey } from '../../env/globals';
import { expect } from '@playwright/test';

Then(
  /^the "([^"]*)" should( not)? contain the following:$/,
  async function(this: ScenarioWorld, elementKey: ElementKey, negate: boolean, dataTable: DataTable) {

    const {
      screen: { page },
      globalConfig
    } = this;

    const flightsToVerify: string[][] = dataTable.raw().slice(1);
    const elementPath = getElementPath(page, elementKey, globalConfig);

    //=====
    await page.waitForTimeout(3000);
    const listFlights = await page.$$eval(elementPath, (rows) => {
      return rows.map(row => {

        const listItemSpans = Array.from(row.querySelectorAll('li > span'));

        const texts = listItemSpans.map(span => span.textContent ? span.textContent.trim() : '');


        const chunkSize = 4;
        const chunkedArrays = [];
        for (let i = 0; i < texts.length; i += chunkSize) {
          const chunk = texts.slice(i, i + chunkSize);
          chunkedArrays.push(chunk);
        }

        return chunkedArrays;
      });
    });

    await page.waitForTimeout(3000);
    function flightExists(flight: string[][]): boolean {
      for (const webFlight of listFlights) {
        if (areFlightsEqual(flight, webFlight)) {
          return true;
        }
      }
      return false;
    }

    function areFlightsEqual(flight1: string[][], flight2: string[][]): boolean {

      for (let i = 0; i < flight1.length; i++) {
        if (flight1[i].join(',') !== flight2[i].join(',')) {
          return false;
        }
      }
      return true;
    }


    for (const flight of flightsToVerify) {
      expect(flightExists([flight])).toBeTruthy();
    }

  });
