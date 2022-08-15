//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

//! Input handler for the main primate views
class MVVInfoDelegate extends WatchUi.BehaviorDelegate {
    private var _index as Number;

    private var _stations;
    private var _num_pages as Number;
    private var _position;

    //! Constructor
    //! @param index The current page index
    public function initialize(index as Number, position) {
        BehaviorDelegate.initialize();
        _index = index;
        _stations = Storage.getValue("stations");
        _stations = mergeStationsAndFavourites(_stations);
        _num_pages = _stations.size();
        _position = position;
    }

    //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        var nextPage = (_index + 1) % _num_pages;
        var view = new $.MVVInfoView(nextPage);
        var delegate = new $.MVVInfoDelegate(nextPage, _position);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);

        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        var prevPage = (_index + _num_pages - 1) % _num_pages;
        var view = new $.MVVInfoView(prevPage);
        var delegate = new $.MVVInfoDelegate(prevPage, _position);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);

        return true;
    }

    public function onSelect() as Boolean {
      queryDepartures();
    }

    public function queryDepartures() {
      var options = {
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :headers => {
          "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
        }
      };

      var id = _stations[_index]["id"];

      Communications.makeWebRequest(
          "https://www.mvg.de/api/fahrinfo/departure/" + id,
          {
            "footway" => 0,
          },
          options,
          self.method(:onDeparturesReceive)
      );
    }

    public function onDeparturesReceive(responseCode as Number, data) {
      if (responseCode == 200) {
        var departures = [];
        for (var i = 0; i < data["departures"].size() && i < 12; i++) {
          var departure = {
            "product" => data["departures"][i]["product"],
            "label" => data["departures"][i]["label"],
            "delay" => data["departures"][i]["delay"],
            "platform" => data["departures"][i]["platform"],
            "destination" => data["departures"][i]["destination"],
            "departureTime" => data["departures"][i]["departureTime"]
          };
          departures.add(departure);
        }

        WatchUi.pushView(new $.DeparturesView(0, departures, _position), new $.DeparturesDelegate(0, departures, _position), WatchUi.SLIDE_UP);
      } else {
        // TODO: Display some error here
      }
    }
}
