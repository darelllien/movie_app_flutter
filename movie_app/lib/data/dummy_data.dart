import '../models/cinema.dart';

class DummyData {
  static List<Cinema> cinemas = [
    Cinema(
      id: 'c1',
      name: 'XXI Cinema',
      logoUrl: 'assets/images/logos/xx1.jpg',
      address: 'Grand Metropolitan Mall, Lantai 4, Bekasi',
      city: 'Bekasi',
      rating: 4.8,
      operatingHours: '10:00 - 22:00 WIB',
    ),
    Cinema(
      id: 'c2',
      name: 'CGV Cinemas',
      logoUrl: 'assets/images/logos/cgv.png',
      address: 'Cyber Park Bekasi, Lantai LG, Jasa Mulya',
      city: 'Bekasi',
      rating: 4.5,
      operatingHours: '11:00 - 23:00 WIB',
    ),
    Cinema(
      id: 'c3',
      name: 'Cinépolis',
      logoUrl: 'assets/images/logos/cinepolis.jpg',
      address: 'Blu Plaza, Lantai 3, Bekasi Timur',
      city: 'Bekasi',
      rating: 4.6,
      operatingHours: '10:00 - 22:00 WIB',
    ),
    Cinema(
      id: 'c4',
      name: 'Flix Cinema',
      logoUrl: 'assets/images/logos/flix.jpg',
      address: 'Grand Galaxy Park, Lantai 2, Jakasetia',
      city: 'Bekasi',
      rating: 4.7,
      operatingHours: '10:30 - 22:00 WIB',
    ),
    Cinema(
      id: 'c5',
      name: 'Platinum Cineplex',
      logoUrl: 'assets/images/logos/platinum.jpg',
      address: 'Suncity Mall, Lantai Wh, Margajaya',
      city: 'Bekasi',
      rating: 4.3,
      operatingHours: '12:00 - 21:30 WIB',
    ),
    Cinema(
      id: 'c6',
      name: 'Plaza Senayan XXI',
      logoUrl: 'assets/images/logos/xx1.jpg',
      address:
          'Plaza Senayan Lt. 5, Jl. Asia Afrika No.8, Gelora, Jakarta Pusat',
      city: 'Jakarta',
      rating: 4.8,
      operatingHours: '11:00 - 22:00',
    ),
    Cinema(
      id: 'c7',
      name: 'CGV Grand Indonesia',
      logoUrl: 'assets/images/logos/cgv.png',
      address:
          'Grand Indonesia West Mall Lt. 8, Jl. M.H. Thamrin No.1, Jakarta Pusat',
      city: 'Jakarta',
      rating: 4.7,
      operatingHours: '10:00 - 22:30',
    ),
    Cinema(
      id: 'c8',
      name: 'Flix Ashta District 8',
      logoUrl: 'assets/images/logos/flix.jpg',
      address:
          'Ashta District 8, SCBD Lot 28, Jl. Jend. Sudirman, Jakarta Selatan',
      city: 'Jakarta',
      rating: 4.9,
      operatingHours: '10:00 - 22:00',
    ),
    Cinema(
      id: 'c9',
      name: 'Cinepolis Pejaten Village',
      logoUrl: 'assets/images/logos/cinepolis.jpg',
      address:
          'Pejaten Village Mall Lt. 3, Jl. Warung Jati Barat, Jakarta Selatan',
      city: 'Jakarta',
      rating: 4.5,
      operatingHours: '11:00 - 21:30',
    ),
    Cinema(
      id: 'c10',
      name: 'CGV FX Sudirman',
      logoUrl: 'assets/images/logos/cgv.png',
      address: 'FX Sudirman Lt. 7, Jl. Jend. Sudirman, Gelora, Jakarta Pusat',
      city: 'Jakarta',
      rating: 4.6,
      operatingHours: '10:00 - 22:00',
    ),
  ];

  static final List<Map<String, String>> movieCast = [
    {
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'name': 'Tom Hanks',
      'role': 'Woody (voice)',
    },
    {
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'name': 'Joan Cusack',
      'role': 'Jessie (voice)',
    },
    {
      'image': 'https://randomuser.me/api/portraits/men/46.jpg',
      'name': 'Tim Allen',
      'role': 'Buzz (voice)',
    },
    {
      'image': 'https://randomuser.me/api/portraits/men/22.jpg',
      'name': 'Don Rickles',
      'role': 'Mr. Potato',
    },
    {
      'image': 'https://randomuser.me/api/portraits/women/12.jpg',
      'name': 'Annie Potts',
      'role': 'Bo Peep',
    },
  ];

  static final Map<String, String> movieCrew = {
    'Sutradara': 'Andrew Stanton',
    'Produser': 'Jessica Choi, Lindsey Collins',
  };

  static final List<Map<String, dynamic>> cinemaSchedules = [
    {
      'cinemaName': 'AEON MALL JGC CGV',
      'type': 'REGULAR 2D',
      'price': 'Rp35.000',
      'showtimes': [
        '13:00',
        '14:20',
        '15:30',
        '16:50',
        '17:50',
        '19:10',
        '20:30',
      ],
      'brand': 'CGV',
    },
    {
      'cinemaName': 'GRAND METROPOLITAN XXI',
      'type': '2D',
      'price': 'Rp50.000',
      'showtimes': ['12:15', '13:45', '14:30', '16:00', '18:15'],
      'brand': 'XXI',
    },
    {
      'cinemaName': 'MEGA BEKASI XXI',
      'type': '2D',
      'price': 'Rp40.000',
      'showtimes': [
        '11:00',
        '12:30',
        '13:45',
        '15:15',
        '16:30',
        '17:45',
        '19:00',
        '20:15',
        '21:30',
      ],
      'brand': 'XXI',
    },
    {
      'cinemaName': 'KOTA KASABLANKA XXI',
      'type': 'PREMIERE',
      'price': 'Rp45.000',
      'showtimes': ['13:10', '15:40', '18:10', '20:40'],
      'brand': 'XXI',
    },
    {
      'cinemaName': 'PLAZA INDONESIA XXI',
      'type': 'PREMIERE',
      'price': 'Rp150.000',
      'showtimes': ['12:00', '14:30', '17:00', '19:30', '21:00'],
      'brand': 'XXI',
    },
    {
      'cinemaName': 'GRAND INDONESIA CGV',
      'type': 'STARIUM 2D',
      'price': 'Rp60.000',
      'showtimes': [
        '11:30',
        '13:50',
        '15:10',
        '17:40',
        '19:10',
        '20:30',
        '21:50',
      ],
      'brand': 'CGV',
    },
    {
      'cinemaName': 'KELAPA GADING XXI',
      'type': 'IMAX 2D',
      'price': 'Rp75.000',
      'showtimes': ['12:45', '15:15', '17:45', '20:15'],
      'brand': 'XXI',
    },
    {
      'cinemaName': 'PONDOK INDAH 2 XXI',
      'type': '2D',
      'price': 'Rp55.000',
      'showtimes': ['12:15', '14:00', '15:45', '17:30', '19:15', '21:00'],
      'brand': 'XXI',
    },
    {
      'cinemaName': 'CENTRAL PARK CGV',
      'type': '4DX 2D',
      'price': 'Rp120.000',
      'showtimes': ['11:10', '13:20', '15:30', '17:40', '19:50', '22:00'],
      'brand': 'CGV',
    },
    {
      'cinemaName': 'SENAYAN CITY XXI',
      'type': 'PREMIERE',
      'price': 'Rp150.000',
      'showtimes': ['13:00', '15:30', '18:00', '20:30'],
      'brand': 'XXI',
    },
  ];
}
