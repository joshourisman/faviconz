require('bootstrap/dist/css/bootstrap.css')

React = require 'react'

MainContainer = React.createClass
    render: () ->
        version = window.version

        <h1>Favi.co.nz {version}</h1>

React.renderComponent <MainContainer />, document.getElementById('content')
