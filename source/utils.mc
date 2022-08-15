import Toybox.Application.Storage;

function mergeStationsAndFavourites(_stations) {
  if (_stations == null) {
    _stations = [];
  }
  var favourites = Storage.getValue("favourites");
  if (favourites != null) {
    for (var i = 0; i < favourites.size(); i++) {
      var favourite = favourites[i];
      var alreadyContained = false;
      for (var j = 0; j < _stations.size(); j++) {
        if (favourite["id"].equals(_stations[i]["id"])) {
          _stations[i]["favourite"] = true;
          alreadyContained = true;
          break;
        }
      }
      if (!alreadyContained) {
        _stations.add(favourite);
      }
    }
  }
  return _stations;
}