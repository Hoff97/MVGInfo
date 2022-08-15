import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application.Storage;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Lang;

class DeparturesView extends WatchUi.View {
    private var _index as Number;
    private var _indicator as PageIndicator;
    private var _position;
    private const COLOR = Graphics.COLOR_BLACK;
    private const IMAGES = {
        "BUS" => $.Rez.Drawables.busIcon,
        "REGIONAL_BUS" => $.Rez.Drawables.busIcon,
        "SBAHN" => $.Rez.Drawables.sbahnIcon,
        "TRAM" => $.Rez.Drawables.tramIcon,
        "UBAHN" => $.Rez.Drawables.ubahnIcon
     };

    private var _departures;

    function initialize(index as Number, departures, position) {
        View.initialize();
        _index = index;

        _departures = departures;

        _position = position;

        var num_pages = _departures.size();
        var margin = 10;
        var selected = Graphics.COLOR_DK_GRAY;
        var notSelected = Graphics.COLOR_LT_GRAY;
        var alignment = $.ALIGN_BOTTOM_CENTER;
        _indicator = new $.PageIndicator(num_pages, selected, notSelected, alignment, margin);
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

        var fontSHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        var fontTHeight = dc.getFontHeight(Graphics.FONT_TINY);

        dc.setColor(COLOR, Graphics.COLOR_TRANSPARENT);
        //dc.drawText((dc.getWidth() / 2), oneFifthHeight, Graphics.FONT_SMALL, _stations[_index]["name"], Graphics.TEXT_JUSTIFY_CENTER);
        //dc.drawText((dc.getWidth() / 2), oneFifthHeight + fontSHeight, Graphics.FONT_TINY, _stations[_index]["distance"] + "m away", Graphics.TEXT_JUSTIFY_CENTER);

        var offset = 25;

        var bitmap = WatchUi.loadResource(IMAGES[_departures[_index]["product"]]) as BitmapResource;
        dc.drawBitmap(5, dc.getHeight() / 2 - offset, bitmap);

        var text = _departures[_index]["label"] + " - " + _departures[_index]["destination"];
        dc.drawText(50, dc.getHeight() / 2 - offset - 10, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_LEFT);

        var difference = (_departures[_index]["departureTime"] / 1000) - Time.now().value();
        var minutes = difference / 60;
        var timeText = "In " + minutes.toString() + " min";
        if (minutes == 0) {
          timeText = "Now";
        } else if (minutes < 0) {
          timeText = (-minutes).toString() + " min ago";
        }
        dc.drawText(50, dc.getHeight() / 2 - offset - 10 + dc.getFontHeight(Graphics.FONT_TINY), Graphics.FONT_TINY, timeText, Graphics.TEXT_JUSTIFY_LEFT);
        var timeWidth = dc.getTextDimensions(timeText, Graphics.FONT_TINY)[0];
        if (_departures[_index]["delay"] != null && _departures[_index]["delay"] > 0) {
          var delayText = " (+" + _departures[_index]["delay"].toString() + ")";
          dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
          dc.drawText(50 + timeWidth, dc.getHeight() / 2 - offset - 10 + dc.getFontHeight(Graphics.FONT_TINY), Graphics.FONT_TINY, delayText, Graphics.TEXT_JUSTIFY_LEFT);
        }

        _indicator.draw(dc, _index);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
