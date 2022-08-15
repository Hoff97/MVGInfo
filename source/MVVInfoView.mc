import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application.Storage;

class MVVInfoView extends WatchUi.View {
    private var _index as Number;
    private var _indicator as PageIndicator;
    private const COLOR = Graphics.COLOR_BLACK;
    private const IMAGES = {
        "BUS" => $.Rez.Drawables.busIcon,
        "REGIONAL_BUS" => $.Rez.Drawables.busIcon,
        "SBAHN" => $.Rez.Drawables.sbahnIcon,
        "TRAM" => $.Rez.Drawables.tramIcon,
        "UBAHN" => $.Rez.Drawables.ubahnIcon
     };

    private var _stations;

    function initialize(index as Number) {
        View.initialize();
        _index = index;

        _stations = Storage.getValue("stations");
        _stations = mergeStationsAndFavourites(_stations);

        var num_pages = _stations.size();
        var margin = 3;
        var selected = Graphics.COLOR_DK_GRAY;
        var notSelected = Graphics.COLOR_LT_GRAY;
        var alignment = $.ALIGN_BOTTOM_CENTER;
        _indicator = new $.PageIndicator(num_pages, selected, notSelected, alignment, margin);
    }

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
                    if (favourite["id"].equals(_stations[j]["id"])) {
                        _stations[j]["favourite"] = true;
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

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function onLayout(dc) {
    }

    // Update the view
    function onUpdate(dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        var oneFifthHeight = dc.getHeight() / 5;
        var fontSHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        var fontTHeight = dc.getFontHeight(Graphics.FONT_TINY);

        dc.setColor(COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText((dc.getWidth() / 2), oneFifthHeight, Graphics.FONT_SMALL, _stations[_index]["name"], Graphics.TEXT_JUSTIFY_CENTER);
        if (_stations[_index]["distance"] != null) {
            dc.drawText((dc.getWidth() / 2), oneFifthHeight + fontSHeight, Graphics.FONT_TINY, _stations[_index]["distance"] + "m away", Graphics.TEXT_JUSTIFY_CENTER);
        }
        if (_stations[_index]["favourite"] != null) {
            var bitmap = WatchUi.loadResource($.Rez.Drawables.starIcon) as BitmapResource;
            dc.drawBitmap(dc.getWidth() / 2 - 16, oneFifthHeight - 35, bitmap);
        }

        var numProducts = _stations[_index]["products"].size();
        var middle = dc.getWidth() / 2;
        var productWidth = 40;
        var padding = 2;
        var totalProductWidth = numProducts*productWidth + padding*(numProducts-1);
        var startProduct = middle - totalProductWidth / 2;

        for (var i = 0; i < numProducts; i++) {
            var positionTop = oneFifthHeight + fontSHeight + fontTHeight;

            var bitmap = WatchUi.loadResource(IMAGES[_stations[_index]["products"][i]]) as BitmapResource;

            var bx = startProduct + i*(productWidth+padding);

            dc.drawBitmap(bx, positionTop, bitmap);

            //dc.drawText((dc.getWidth() / 2), position, Graphics.FONT_TINY, _stations[_index]["products"][i], Graphics.TEXT_JUSTIFY_CENTER);
        }

        _indicator.draw(dc, _index);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
