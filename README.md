# Cosmetic Shop App

Cosmetic Shop is a full-featured application that allows users to browse cosmetic products, add items to cart, save favorites, and place orders.

- **User Authentication** - Sign up, Sign in with Firebase Auth
- **Product Catalog** - Browse cosmetic products with images, prices, and descriptions
- **Shopping Cart** - Add/remove items, update quantities, calculate total price
- **Favorites** - Save favorite products
- **Order History** - View past orders (stored locally)
- **Search** - Search products by name or description
- **Theme Toggle** - Switch between light and dark mode
- **Responsive UI** - Grid layout that adapts to different screen sizes


| Requirement | Implementation |
|-------------|----------------|
| Responsive UI (Scaffold, Column, Row, Container) | Used throughout all screens |
| Complex scrollable view (GridView) | Home screen product grid |
| Interactive widgets | Buttons, icons, snackbars, search bar |
| go_router navigation | 7 routes with parameters |
| Clean Architecture | UI / Domain / Data layers separated |
| Riverpod state management | Cart, Favorites, Auth, Theme providers |
| External API with HTTP | DummyJSON products API |
| JSON serialization | Products parsed to Dart models |
| Shared Preferences | Theme preference saved |
| Firebase Authentication | Sign up, Sign in | 
