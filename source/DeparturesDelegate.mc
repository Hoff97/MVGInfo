//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

//! Input handler for the main primate views
class DeparturesDelegate extends WatchUi.BehaviorDelegate {
    private var _index as Number;

    private var _departures;
    private var _num_pages as Number;
    private var _position;

    //! Constructor
    //! @param index The current page index
    public function initialize(index as Number, departures, position) {
        BehaviorDelegate.initialize();
        _index = index;
        _departures = departures;
        _num_pages = _departures.size();
        _position = position;
    }

    //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        var nextPage = (_index + 1) % _num_pages;
        var view = new $.DeparturesView(nextPage, _departures, _position);
        var delegate = new $.DeparturesDelegate(nextPage, _departures, _position);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);

        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        var prevPage = (_index + _num_pages - 1) % _num_pages;
        var view = new $.DeparturesView(prevPage, _departures, _position);
        var delegate = new $.DeparturesDelegate(prevPage, _departures, _position);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);

        return true;
    }
}
