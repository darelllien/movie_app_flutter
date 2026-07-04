import '../models/cinema.dart';

class DummyData {
  static List<Cinema> cinemas = [
    Cinema(
      id: 'c1',
      name: 'XXI Cinema',
      logoUrl:
          'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=500&auto=format&fit=crop&q=60', // Gambar representasi bioskop
      address: 'Grand Metropolitan Mall, Lantai 4, Bekasi',
      rating: 4.8,
      operatingHours: '10:00 - 22:00 WIB',
    ),
    Cinema(
      id: 'c2',
      name: 'CGV Cinemas',
      logoUrl:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500&auto=format&fit=crop&q=60',
      address: 'Cyber Park Bekasi, Lantai LG, Jasa Mulya',
      rating: 4.5,
      operatingHours: '11:00 - 23:00 WIB',
    ),
    Cinema(
      id: 'c3',
      name: 'Cinépolis',
      logoUrl:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=500&auto=format&fit=crop&q=60',
      address: 'Blu Plaza, Lantai 3, Bekasi Timur',
      rating: 4.6,
      operatingHours: '10:00 - 22:00 WIB',
    ),
    Cinema(
      id: 'c4',
      name: 'Flix Cinema',
      logoUrl:
          'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500&auto=format&fit=crop&q=60',
      address: 'Grand Galaxy Park, Lantai 2, Jakasetia',
      rating: 4.7,
      operatingHours: '10:30 - 22:00 WIB',
    ),
    Cinema(
      id: 'c5',
      name: 'Platinum Cineplex',
      logoUrl:
          'https://images.unsplash.com/photo-1574267432553-4b4628081c31?w=500&auto=format&fit=crop&q=60',
      address: 'Suncity Mall, Lantai Wh, Margajaya',
      rating: 4.3,
      operatingHours: '12:00 - 21:30 WIB',
    ),
  ];
}
