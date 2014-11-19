var webpack = require('webpack');
var path = require('path');

module.exports = {
  entry: './src/index.cjsx',
  output: {
    path: path.join(__dirname, '../static'),
    publicPath: '/static/',
    filename: 'js/bundle.js'
  },
  resolveLoader: {
                modulesDirectories: ['node_modules', ]
        },
  module: {
    loaders: [
      { test: /\.cjsx$/, loaders: ['coffee', 'cjsx']},
      { test: /\.coffee$/, loader: 'coffee'},
      { test: /\.css$/, loader: 'style-loader!css-loader'},
      {
        test: /\.(svg|woff|ttf|eot)/,
        loader: 'url-loader',
        query: {
          limit: 8192,
          name: 'fonts/[hash].[ext]'
        }
      }
    ]
  },
  resolve: {
    modulesDirectories: ['./src', 'node_modules'],
    extensions: ['', '.js', '.cjsx', '.coffee']
  },
  plugins: [
    new webpack.DefinePlugin({'process.env': {NODE_ENV: JSON.stringify("production")}}),
    new webpack.optimize.OccurenceOrderPlugin(true),
    new webpack.optimize.DedupePlugin()
  ]
};
