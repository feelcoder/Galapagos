window.ConsoleWidget = Ractive.extend({
  data: {
    input: '',
    agentTypes: ['observer', 'turtles', 'patches', 'links'],
    agentTypeIndex: 0,
    history: [], # Array of {agentType, input} objects
    historyIndex: 0,
    workingEntry: {}, # Stores {agentType, input} when user up arrows
    output: '',
    scroll: 0
  }
  computed: {
    agentType: {
      get: -> @get('agentTypes')[@get('agentTypeIndex')]
      set: (val) ->
        index = @get('agentTypes').indexOf(val)
        if index >= 0
          @set('agentTypeIndex', index)
    }
  }

  onrender: ->
    changeAgentType = =>
      @set('agentTypeIndex', (@get('agentTypeIndex') + 1) % @get('agentTypes').length)

    moveInHistory = (index) =>
      newIndex = @get('historyIndex') + index
      if newIndex < 0
        newIndex = 0
      else if newIndex > @get('history').length
        newIndex = @get('history').length
      if @get('historyIndex') == @get('history').length
        @set('workingEntry', {agentType: @get('agentType'), input: @get('input')})
      if newIndex == @get('history').length
        @set(@get('workingEntry'))
      else
        entry = @get('history')[newIndex]
        @set(entry)
      @set('historyIndex', newIndex)

    @on('change-mode', (event) ->
      switch event.original.which
        when TAB_KEY
          changeAgentType()
          false
        when UP_KEY
          moveInHistory(-1)
          false
        when DOWN_KEY
          moveInHistory(1)
          false
        else true
    )
    @on('check-run', (event) ->
      if event.original.which == ENTER_KEY
        input = @get('input')
        agentType = @get('agentType')
        @set('output', "#{@get('output')}#{agentType}> #{input}\n")
        history = @get('history')
        lastEntry = if history.length > 0 then history[history.length - 1] else {agentType: '', input: ''}
        if lastEntry.input != input or lastEntry.agentType != agentType
          history.push({agentType, input})
        @set('historyIndex', history.length)
        if agentType != 'observer'
          input = "ask #{agentType} [ #{input} ]"
        @fire('run', input)
        @set('input', '')
        @set('workingEntry', {})
    )
    @observe('output', ->
      @update('output')
      outputElem = @find('.netlogo-command-center-output')
      outputElem.scrollTop = outputElem.scrollHeight
    )

  template:
    """
    <div class='netlogo-command-center netlogo-widget'>
      <pre class='netlogo-command-center-output' scrollTop={{scroll}}>{{output}}</pre>

      <div class='netlogo-command-center-input'>
        <label>
          <select value="{{agentType}}">
          {{#agentTypes}}
            <option value="{{.}}">{{.}}</option>
          {{/}}
          </select>
        </label>
        <input type='text'
               on-keypress='check-run'
               on-keydown='change-mode'
               value='{{input}}' />
      </div>
    </div>
    """
})

ENTER_KEY = 13
TAB_KEY = 9
UP_KEY = 38
DOWN_KEY = 40