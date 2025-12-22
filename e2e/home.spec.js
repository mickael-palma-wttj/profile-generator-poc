// @ts-check
const { test, expect } = require('@playwright/test');

test('has title', async ({ page }) => {
    await page.goto('/');

    // Expect a title "to contain" a substring.
    await expect(page).toHaveTitle(/Company Profile Generator/);
});

test('has heading', async ({ page }) => {
    await page.goto('/');

    // Expects page to have a heading with the name of Installation.
    await expect(page.getByRole('heading', { name: 'Company Profile Generator' })).toBeVisible();
});

test('has generation form', async ({ page }) => {
    await page.goto('/');

    // Check for the form
    const form = page.locator('#generate-form');
    await expect(form).toBeVisible();

    // Check for inputs
    await expect(page.getByLabel('Company Name')).toBeVisible();
    await expect(page.getByLabel('Website')).toBeVisible();
});
