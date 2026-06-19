
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: { sans: ['"Plus Jakarta Sans"', 'sans-serif'] },
          colors: {
            white: '#FFFFFF',
            offwhite: '#F3F8FE',
            silver: '#E2E8F0',
            ink: '#212121',
            muted: '#4D5652',
            primary: '#176FF2'
          },
          transitionTimingFunction: {
            'haptic': 'cubic-bezier(0.32, 0.72, 0, 1)'
          },
          boxShadow: {
            'glass': '0 24px 60px -12px rgba(0,0,0,0.05)',
            'glass-hover': '0 32px 80px -10px rgba(0,0,0,0.08)',
            'inner-glow': 'inset 0 1px 1px rgba(255,255,255,0.8)'
          }
        }
      }
    }
  