import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Communications;
import Toybox.Application.Storage;


(:glance)
class MVVInfoApp extends Application.AppBase {
  private var _glanceView as MVVGlanceView;
  private var _position as Position.Position;
  private var _lastFetchPosition as Position.Position;

  function initialize() {
    AppBase.initialize();
    _glanceView = new $.MVVGlanceView();
  }

    // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    Position.enableLocationEvents({
      :acquisitionType => Position.LOCATION_CONTINUOUS,
    }, self.method(:onPosition));

    queryFavourites();
    var favourites = Storage.getValue("favourites");
    var stations = Storage.getValue("stations");
    if (favourites != null && favourites.size() > 0) {
      _glanceView.setInfo(favourites[0]["name"], null, 200);
    } else if (stations != null && stations.size() > 0) {
      _glanceView.setInfo(stations[0]["name"], stations[0]["distance"], 200);
    }
  }

    // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    Position.enableLocationEvents({
        :acquisitionType => Position.LOCATION_DISABLE,
    }, self.method(:onPosition));
  }

  public function computeDistance(pos1, pos2) {
    var lat1, lat2, lon1, lon2, lat, lon;
    var dx, dy, distance;

    lat1 = pos1.toDegrees()[0].toFloat();
    lon1 = pos1.toDegrees()[1].toFloat();
    lat2 = pos2.toDegrees()[0].toFloat();
    lon2 = pos2.toDegrees()[1].toFloat();

    lat = (lat1 + lat2) / 2 * 0.01745;
    dx = 111.3 * Math.cos(lat) * (lon1 - lon2);
    dy = 111.3 * (lat1 - lat2);
    distance = 1000 * Math.sqrt(dx * dx + dy * dy);
    distance = distance.toNumber();
    return distance;
  }

  public function onPosition(info as Position.Info) as Void {
    _position = info.position;

    if (_lastFetchPosition == null || computeDistance(_position, _lastFetchPosition) > 200) {
      _lastFetchPosition = _position;
      self.queryStations();
    }
  }

  public function onSettingsChanged() {
    queryFavourites();
  }

  public function queryFavourites() as Void {
    Storage.setValue("favourites", []);

    var options = {
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
      }
    };

    var favourites = Properties.getValue("favourites");
    if (favourites != null) {
      for (var i = 0; i < favourites.size(); i++) {
        var favouriteName = favourites[i]["name"];
        Communications.makeWebRequest(
          "https://www.mvg.de/api/fahrinfo/location/queryWeb",
          {
            "q" => favouriteName,
            "limit" => 10
          },
          options,
          self.method(:onFavouriteReceive)
        );
      }
    }
  }

  public function onFavouriteReceive(responseCode as Number, data) {
    if (responseCode == 200) {
      if (data["locations"].size() > 0) {
        var favouritesStorage = Storage.getValue("favourites");
        var station = {
          "name" => data["locations"][0]["name"],
          "id" => data["locations"][0]["id"],
          "products" => data["locations"][0]["products"],
        };
        favouritesStorage.add(station);
        Storage.setValue("favourites", favouritesStorage);

        _glanceView.setInfo(favouritesStorage[0]["name"], null, responseCode);
      }
    }
  }

  public function queryStations() as Void {
    var options = {
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
      }
    };

    Communications.makeWebRequest(
        "https://www.mvg.de/api/fahrinfo/location/nearby",
        {
          "latitude" => _position.toDegrees()[0].toString(),
          "longitude" => _position.toDegrees()[1].toString()
        },
        options,
        self.method(:onLocationReceive)
    );
  }

  public function onLocationReceive(responseCode as Number, data) {
    if (responseCode == 200) {
      _glanceView.setInfo(data["locations"][0]["name"], data["locations"][0]["distance"], responseCode);

      var stationLen = 5;
      if (data["locations"].size() < stationLen) {
        stationLen = data["locations"].size();
      }

      var stations = [];
      for (var i = 0; i < stationLen; i++) {
        var station = {
          "name" => data["locations"][i]["name"],
          "distance" => data["locations"][i]["distance"],
          "id" => data["locations"][i]["id"],
          "products" => data["locations"][i]["products"],
        };
        stations.add(station);
      }
      Storage.setValue("stations", stations);
    } else {
      _glanceView.setInfo(null, null, responseCode);
    }
  }

  function getGlanceView() {
    return [ _glanceView ];
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    return [ new $.MVVInfoView(0), new $.MVVInfoDelegate(0, _position) ] as Array<Views or InputDelegates>;
  }

  function log(message) {
    var now = System.getClockTime();
    System.print(now.hour.format("%02d") + ":" + now.min.format("%02d") + ":" + now.sec.format("%02d") + " ");
    System.println(message);
  }

}

function getApp() as MVVInfoApp {
    return Application.getApp() as MVVInfoApp;
}