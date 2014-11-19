require('bootstrap/dist/css/bootstrap.css')

React = require 'react'
keyMirror = require 'react/lib/keyMirror'
Fluxxor = require 'fluxxor'

constants = keyMirror
    LOAD_FAVI: null
    LOAD_FAVI_SUCCESS: null
    LOAD_FAVI_FAIL: null

    UPDATE_DOMAIN: null

FaviStore = Fluxxor.createStore
    initialize: () ->
        @newDomainText = ''
        @favis = []

        @bindActions(
            constants.LOAD_FAVI, @onLoadFavi,
            constants.LOAD_FAVI_SUCCESS, @onLoadFaviSuccess,
            constants.LOAD_FAVI_FAIL, @onLoadFaviFail,
            constants.UPDATE_DOMAIN, @onUpdateDomain,
        )

    onLoadFavi: (payload) ->
        @favis.push payload
        @newDomainText = ''
        @emit 'change'

    onUpdateDomain: (payload) ->
        @newDomainText = payload.domain
        @emit 'change'

    onLoadFaviSuccess: (data) ->
        console.log data

    onLoadFaviFail: (err) ->
        console.log err

    getState: () ->
        newDomainText: @newDomainText
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
                @dispatch constants.LOAD_FAVI_FAIL, err

    updateDomain: (domain) ->
        @dispatch constants.UPDATE_DOMAIN, {domain: domain}

stores =
    FaviStore: new FaviStore()

flux = new Fluxxor.Flux stores, actions
flux.on "dispatch", (type, payload) ->
    console.log "[Dispatch]", type, payload

FluxMixin = Fluxxor.FluxMixin React
StoreWatchMixin = Fluxxor.StoreWatchMixin

Application = React.createClass
    mixins: [FluxMixin, StoreWatchMixin "FaviStore"]

    getStateFromFlux: () ->
        @getFlux().store("FaviStore").getState()

    onSubmitForm: (e) ->
        e.preventDefault()
        @getFlux().actions.loadFavi @state.newDomainText

    handleDomainTextChange: (e) ->
        @getFlux().actions.updateDomain e.target.value

    render: () ->
        version = window.version

        <div>
            <h1>Favi.co.nz {version}</h1>
            <form onSubmit={@onSubmitForm}>
                http://<input type="text" placeholder="Domain"
                       value={@state.newDomainText}
                       onChange={@handleDomainTextChange} />
                <input type="submit" value="Get Favicon" />
            </form>
            <ul>
                {@state.favis.map (favi, i) ->
                    <li key={i}>{favi}</li>}
            </ul>
        </div>

React.renderComponent <Application flux={flux} />, document.getElementById('content')
