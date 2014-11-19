require('bootstrap/dist/css/bootstrap.css')

_ = require 'lodash-node'
React = require 'react'
keyMirror = require 'react/lib/keyMirror'
Fluxxor = require 'fluxxor'

bs = require 'react-bootstrap'
Button = bs.Button

constants = keyMirror
    LOAD_FAVI: null
    LOAD_FAVI_SUCCESS: null
    LOAD_FAVI_FAIL: null

    UPDATE_DOMAIN: null

FaviStore = Fluxxor.createStore
    initialize: () ->
        @newDomainText = ''
        @validDomain = false
        @favis = {}

        @bindActions(
            constants.LOAD_FAVI, @onLoadFavi,
            constants.LOAD_FAVI_SUCCESS, @onLoadFaviSuccess,
            constants.LOAD_FAVI_FAIL, @onLoadFaviFail,
            constants.UPDATE_DOMAIN, @onUpdateDomain,
        )

    onLoadFavi: (payload) ->
        @favis[payload.domain] =
            domain: payload.domain
            loading: true
        @newDomainText = ''
        @emit 'change'

    onUpdateDomain: (payload) ->
        @newDomainText = payload.domain
        @validDomain = true
        @emit 'change'

    onLoadFaviSuccess: (data) ->
        @favis[data.url]['loading'] = false
        @favis[data.url]['succeeded'] = true
        @favis[data.url]['favicon_url'] = data.favicon_url
        @emit 'change'

    onLoadFaviFail: (domain) ->
        @favis[domain]['loading'] = false
        @favis[domain]['succeeded'] = false
        @emit 'change'

    getState: () ->
        newDomainText: @newDomainText
        validDomain: @validDomain
        favis: @favis

actions =
    loadFavi: (domain) ->
        @dispatch constants.LOAD_FAVI, {domain: domain}

        $.ajax
            url: '/api/v1/favicons/' + domain + '/'
            dataType: 'json'
            success: (data) =>
                @dispatch constants.LOAD_FAVI_SUCCESS, data
            error: (xhr, status, err) =>
                @dispatch constants.LOAD_FAVI_FAIL, domain

    updateDomain: (domain) ->
        @dispatch constants.UPDATE_DOMAIN, {domain: domain}

stores =
    FaviStore: new FaviStore()

flux = new Fluxxor.Flux stores, actions

FluxMixin = Fluxxor.FluxMixin React
StoreWatchMixin = Fluxxor.StoreWatchMixin

Application = React.createClass
    mixins: [FluxMixin, StoreWatchMixin "FaviStore"]

    getStateFromFlux: () ->
        @getFlux().store("FaviStore").getState()

    loadFavi: () ->
        @getFlux().actions.loadFavi @state.newDomainText

    handleDomainTextChange: (e) ->
        @getFlux().actions.updateDomain e.target.value

    faviObjects: () ->
        _.values @state.favis

    render: () ->
        version = window.version
        buttonState = if @state.validDomain then '' else 'disabled="disabled"'

        <div>
            <h1>Favi.co.nz {version}</h1>
            http://<input type="text" placeholder="Domain"
                   value={@state.newDomainText}
                   onChange={@handleDomainTextChange} />&nbsp;
            <Button onClick={@loadFavi} bsStyle="primary">Get Favicon</Button>
            <ul>
                {@faviObjects().map (favi, i) ->
                    <Favi key={i} favi=favi />}
            </ul>
        </div>

Favi = React.createClass
    mixins: [FluxMixin]

    render: () ->
        content = ''
        if @props.favi.loading
            content = 'loading…'
        else if not @props.favi.succeeded
            content = 'failed to load.'
        else
            content = <img src={@props.favi.favicon_url} />

        <li>{@props.favi.domain}: {content}</li>

React.renderComponent <Application flux={flux} />, document.getElementById('content')
