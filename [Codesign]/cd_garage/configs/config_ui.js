window['CONFIG'] = {
    allowed_plate_characters: /[^a-zA-Z0-9]/g,

    // Disables / enables these options completely without allowing players to change them
    allow_vehicle_images: true,
    allow_vehicle_rename: true,

    // These are the default values, they can be changed in the settings menu by players
    // This only works if the options above are set to true
    vehicle_images: true,
    vehicle_rename: true,

    // Used for the raid plate search system
    // The maximum length is forced to 8 characters
    plate_length: 8,
}