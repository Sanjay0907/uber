class CommonFunctions {
  static getRideStatus(int rideStatusNum) {
    switch (rideStatusNum) {
      case 0:
        return 'WAITING_FOR_RIDE_REQUEST';

      case 1:
        return 'WAITING_FOR_DRIVER_TO_ARRIVE';

      case 2:
        return 'MOVING_TOWARDS_DESTINATION';

      case 3:
        return 'RIDE_COMPLETED';
    }
  }
}
