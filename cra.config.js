module.exports = {
    // Load plugins by name and/or by reference. Loading plugins by name is for
    // convenience, eg. `'css-modules'` is the same as `require('react-scripts-plugin-css-modules')`
    plugins: ['no-minify'],
  
    // Webpack configuration
    apply: (config, { env, paths }) => {
      return config;
    },
  
    // Babel configuration
    babel: (config, { env, paths }) => {
      return config;
    },
  };
  