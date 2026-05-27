/// Po wyjściu z ekranu czatu, provider żyje przez ten czas, by stream
/// mógł dokończyć w tle / user mógł wrócić bez restartowania (manifest 7.7).
const Duration kStreamKeepAliveTimeout = Duration(minutes: 5);
