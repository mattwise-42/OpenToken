# Custom Theme Documentation

## Overview

This directory contains the custom Truveta-inspired theme for the OpenToken documentation site.

## Design Principles

The theme follows modern healthcare technology design aesthetics inspired by Truveta.com:

### Color Palette

- **Primary Dark**: `#0a0e27` - Main header background
- **Secondary Dark**: `#1a1f3a` - Navigation and accents
- **Accent Blue**: `#3b82f6` - Links, CTAs, highlights
- **Accent Teal**: `#06b6d4` - Secondary accents
- **Text Light**: `#f8fafc` - Light text on dark backgrounds
- **Text Gray**: `#cbd5e1` - Muted text

### Typography

- **Font Family**: System fonts (-apple-system, BlinkMacSystemFont, Segoe UI, Roboto)
- **Headings**: Bold, tight letter-spacing, color-coded by level
- **Body**: Comfortable line-height (1.7) for readability
- **Code**: Monospace with distinct background colors

### Components

#### Headers
- Gradient background (dark blue tones)
- Clean typography with prominent project name
- Blue accent border at bottom

#### Navigation
- Horizontal menu with smooth hover effects
- Responsive mobile-friendly dropdown
- Active state indicators

#### Content Cards
- Feature grid with hover effects
- Elevation on hover (shadow + transform)
- Clean borders with rounded corners

#### Tables
- Dark gradient headers
- Striped rows on hover
- Rounded corners with box shadow

#### Code Blocks
- Dark background for better contrast
- Syntax highlighting via Rouge
- Inline code with distinct pink highlight

#### Buttons/CTAs
- Primary blue with hover lift effect
- Shadow transitions for depth
- Consistent padding and border-radius

## File Structure

```
docs/
├── _layouts/
│   └── default.html          # Main layout template
├── assets/
│   └── css/
│       └── style.scss        # Custom styles (SCSS)
└── _config.yml               # Jekyll configuration
```

## Customization

### Changing Colors

Edit the CSS custom properties in `assets/css/style.scss`:

```scss
:root {
  --primary-dark: #0a0e27;
  --accent-blue: #3b82f6;
  /* ... other variables */
}
```

### Adding Navigation Items

Edit `_config.yml`:

```yaml
navigation:
  - title: New Page
    url: /new-page
```

### Modifying Layout

Edit `_layouts/default.html` to change the HTML structure.

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Responsive design for mobile, tablet, and desktop
- CSS Grid and Flexbox for layouts

## Performance

- Minimal external dependencies (only KaTeX for math)
- Optimized CSS with no unused styles
- Fast page loads with static generation

## Accessibility

- Semantic HTML5 elements
- Proper heading hierarchy
- Sufficient color contrast ratios
- Keyboard navigation support

## License

Custom theme created for OpenToken project. Free to use and modify.
