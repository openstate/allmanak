import categoriesJson from './routes/_categories.json';
import { writable, readable } from 'svelte/store';

export const showReportModal = writable(false);
export const categories = readable(categoriesJson);
