import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@services': path.resolve(__dirname, './src/services'),
      '@store': path.resolve(__dirname, './src/store'),
      '@types': path.resolve(__dirname, './src/types'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@theme': path.resolve(__dirname, './src/theme')
    }
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      }
    }
  },
  // ============================================================================
  // BUILD OPTIMIERUNGEN FÜR PRODUKTION
  // ============================================================================
  build: {
    // Chunk-Größen-Warnung
    chunkSizeWarningLimit: 500,

    // Komprimierte Größe anzeigen
    reportCompressedSize: true,

    // Source Maps für Produktion (auskommentieren für Debugging)
    sourcemap: false,

    // Rollup Optionen für besseres Chunking
    rollupOptions: {
      output: {
        // Manuelle Chunk-Aufteilung für besseres Caching
        manualChunks: {
          // Vendor Chunks - werden selten aktualisiert
          'vendor-react': ['react', 'react-dom', 'react-router-dom'],
          'vendor-mui': ['@mui/material', '@mui/icons-material', '@mui/x-date-pickers'],
          'vendor-utils': ['axios', 'zustand', 'date-fns'],
        },
        // Chunk-Dateinamen mit Hash für Caching
        chunkFileNames: 'assets/js/[name]-[hash].js',
        entryFileNames: 'assets/js/[name]-[hash].js',
        assetFileNames: 'assets/[ext]/[name]-[hash].[ext]'
      }
    },

    // Minifizierung
    minify: 'esbuild',

    // Target für moderne Browser
    target: 'es2020'
  },

  // ============================================================================
  // OPTIMIERUNGEN
  // ============================================================================
  optimizeDeps: {
    // Pre-bundle diese Abhängigkeiten
    include: [
      'react',
      'react-dom',
      'react-router-dom',
      '@mui/material',
      '@mui/icons-material',
      'axios',
      'zustand',
      'date-fns'
    ]
  },

  // CSS Code-Splitting
  css: {
    devSourcemap: true
  }
});
