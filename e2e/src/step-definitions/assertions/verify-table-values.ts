import { DataTable, Then } from '@cucumber/cucumber';
import { getElementPath } from '../support/web-element-helper';
import { ElementKey } from '../../env/globals';
import { ScenarioWorld } from '../setup/world';
import { expect } from '@playwright/test'


Then(
  /^the "([^"]*)" should( not)? equal the following:$/,
  async function(this: ScenarioWorld, elementKey: ElementKey, negate: boolean, dataTable: DataTable) {

    const {
      screen: { page },
      globalConfig
    } = this;

    const elementPath = getElementPath(page, elementKey, globalConfig);


    await page.waitForTimeout(3000);
    const listElements = await page.$$eval(elementPath, (rows) => {
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
    const dataTableRows: string[][] = dataTable.raw();
    const listItemChunks: string[][][] = listElements;

    function verifyRowsAgainstItemChunks(dataTableRows: string[][], itemChunks: string[][][]): boolean {
      return dataTableRows.every(dataTableRow => {
        const firstElement = dataTableRow[0];

        const isFirstElementPresentInAnyChunk = itemChunks.some(chunks =>
          chunks.some(flightChunk => flightChunk[0] === firstElement)
        );

        if (!isFirstElementPresentInAnyChunk) {
          return false;
        }

        return itemChunks.some(chunks =>
          chunks.some(itemChunk =>
            dataTableRow.every((item, index) => item === itemChunk[index])
          )
        );
      });
    }

    const verificationResult: boolean = verifyRowsAgainstItemChunks(dataTableRows, listItemChunks);

    expect(verificationResult).toBe(true)
  });
