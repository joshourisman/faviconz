require('bootstrap/dist/css/bootstrap.css')

React = require 'react'

MainContainer = React.createClass
    render: () ->
        <h1>Favi.co.nz</h1>

React.renderComponent <MainContainer />, document.getElementById('content')
