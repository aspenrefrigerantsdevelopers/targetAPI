Type.registerNamespace('AtlasNotes.UI');

AtlasNotes.UI.TextChangedBehavior = function() {
    AtlasNotes.UI.TextChangedBehavior.initializeBase(this);
    
    // Private members.
    var _text;
    var _timeout = 500;
    var _timer;
    var _keydownHandler;
    var _keyupHandler;
    var _tickHandler;
    
    // Properties.
    this.get_timeout = function() {
        return _timeout;
    }
    this.set_timeout = function(value) {
        if(value != _timeout) {
            _timeout = value;
            if(_timer) {
                _timer.set_interval(_timeout);
            }
            this.raisePropertyChanged('timeout');
        }
    }
    // Events.
    this.changed = this.createEvent();
    
    // Initialize / Dispose.
    this.initialize = function() {
        AtlasNotes.UI.TextChangedBehavior.callBaseMethod(this, 'initialize');
        _text = this.control.element.value;
        _tickHandler = Function.createDelegate(this, this._onTimerTick);
        
        _timer = new Sys.Timer();
        _timer.set_interval(_timeout);
        _timer.tick.add(_tickHandler);
        
        _keydownHandler = Function.createDelegate(this, keydownHandler);
        this.control.element.attachEvent('onkeydown', _keydownHandler);
        
        _keyupHandler = Function.createDelegate(this, keyupHandler);
        this.control.element.attachEvent('onkeyup', _keyupHandler);
    }
    this.dispose = function() {
        if(_timer) {
            _timer.tick.remove(_tickHandler);
            _timer.dispose();
            _timer = null;
        }
        _tickHandler = null;
        
        this.control.element.detachEvent('onkeydown', _keydownHandler);
        _keydownHandler = null;
        
        this.control.element.detachEvent('onkeyup', _keyupHandler);
        _keyupHandler = null;
  // The following call to removeObject avoids the following warning
    // when a control is reloaded within an UpdatePanel:
    // Assertion Failed: Duplicate use of id "XXX" for object of type
    // "AtlasControlToolkit.YYY".
    var applicationMarkupContext = Sys.Application.getMarkupContext();
    if (applicationMarkupContext) {
        applicationMarkupContext.removeObject(this);
    }          
        AtlasNotes.UI.TextChangedBehavior.callBaseMethod(this, 'dispose');

    }
    
    // Descriptor.
    this.getDescriptor = function() {
        var td = AtlasNotes.UI.TextChangedBehavior.callBaseMethod(this, 'getDescriptor');
        
        td.addProperty('timeout', Number);
        td.addEvent('changed', true);
        
        return td;
    }
    
    // Event Handlers.
    function keydownHandler() {
        _timer.set_enabled(false);
    }
    function keyupHandler() {
        var e = window.event;
        if (e.keyCode != Sys.UI.Key.Tab) {
            _timer.set_enabled(true);
        }        
    }
    this._onTimerTick = function() {
        _timer.set_enabled(false);
        
        if(_text != this.control.element.value) {
            _text = this.control.element.value;
            
            this.changed.invoke(this, Sys.EventArgs.Empty);
        }
    }
}
AtlasNotes.UI.TextChangedBehavior.registerClass('AtlasNotes.UI.TextChangedBehavior', Sys.UI.Behavior);
Sys.TypeDescriptor.addType('script', 'textChangedBehavior', AtlasNotes.UI.TextChangedBehavior);

