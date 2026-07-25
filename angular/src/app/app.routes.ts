import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/catalog',
    pathMatch: 'full',
  },
  {
    path: 'auth',
    loadComponent: () => import('./pages/auth-page/auth-page.component').then(m => m.AuthPageComponent),
  },
  {
    path: 'catalog',
    loadComponent: () => import('./pages/catalog-page/catalog-page.component').then(m => m.CatalogPageComponent),
  },
  {
    path: 'cart',
    loadComponent: () => import('./pages/cart-page/cart-page.component').then(m => m.CartPageComponent),
  },
  {
    path: 'checkout',
    loadComponent: () => import('./pages/checkout-page/checkout-page.component').then(m => m.CheckoutPageComponent),
  },
  {
    path: 'admin',
    loadComponent: () => import('./pages/admin-page/admin-page.component').then(m => m.AdminPageComponent),
  },
  {
    path: '**',
    loadComponent: () => import('./pages/page-not-found/page-not-found.component').then(m => m.PageNotFoundComponent),
  },
];
