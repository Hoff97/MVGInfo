using Toybox.WatchUi;
using Toybox.Graphics as Gfx;

(:glance)
class MVVGlanceView extends WatchUi.GlanceView {

  private var _nearestLocationName;
  private var _nearestLocationDistance;
  private var _responseCode;

  function initialize() {
    GlanceView.initialize();
  }

  function onLayout(dc) {
  }

  function onUpdate(dc) {
    if (_nearestLocationName != null) {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
      dc.drawText(0, 0, Graphics.FONT_TINY, _nearestLocationName, Graphics.TEXT_JUSTIFY_LEFT);
      if (_nearestLocationDistance != null) {
        dc.drawText(0, dc.getFontHeight(Graphics.FONT_TINY), Graphics.FONT_XTINY, _nearestLocationDistance.toString() + "m", Graphics.TEXT_JUSTIFY_LEFT);
      }
    } else if (_responseCode != null) {
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
      dc.drawText(0, 0, Graphics.FONT_TINY, responseCode.toString(), Graphics.TEXT_JUSTIFY_LEFT);
    } else {
      var infoText = "Couldnt get station info";
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
      dc.drawText(0, 0, Graphics.FONT_TINY, infoText, Graphics.TEXT_JUSTIFY_LEFT);
    }
  }

  public function setInfo(nearestLocationName, nearestLocationDistance, responseCode) {
    _nearestLocationName = nearestLocationName;
    _nearestLocationDistance = nearestLocationDistance;
    _responseCode = responseCode;

    WatchUi.requestUpdate();
  }
}