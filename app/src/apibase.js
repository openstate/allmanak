const version = 'v1';
export const apiBaseBrowserProduction = `https://rest-api.allmanak.nl/${version}`;
export const apiBaseBrowserDevelopment = `/rest-api/${version}`;
export const apiBaseBrowser = process.env.NODE_ENV === 'development' ? apiBaseBrowserDevelopment : apiBaseBrowserProduction;
export const apiBaseNode = `http://api-rest-${version}:3000`;

export const apiBaseUri = process.browser ? apiBaseBrowser : apiBaseNode;