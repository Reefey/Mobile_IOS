import Foundation

struct ThumbnailMapper {
    // Dictionary mapping scientific name prefixes (first two words) to thumbnail asset names
    // Based on the marine_rows-3.csv file scientific names
    private static let scientificNameToThumbnail: [String: String] = [
        // Fishes
        "amphiprion ocellaris": "amphiprion_ocellaris", // Clownfish
        "paracanthurus hepatus": "paracanthurus_hepatus", // Blue Tang
        "chelonia mydas": "chelonia_mydas", // Sea Turtle
        "mobula alfredi": "mobula_alfredi", // Manta Ray
        "octopus cyanea": "octopus_cyanea", // Reef Octopus
        "mola alexandrini": "mola_alexandrini", // Ocean sunfish
        "carcharhinus melanopterus": "carcharhinus_melanopterus", // Blacktip reef shark
        "triaenodon obesus": "triaenodon_obesus", // Whitetip reef shark
        "carcharhinus amblyrhynchos": "carcharhinus_amblyrhynchos", // Grey reef shark
        "taeniura lymma": "taeniura_lymma", // Blue-spotted ribbontail ray
        "aetobatus ocellatus": "aetobatus_ocellatus", // Spotted eagle ray
        "synanceia verrucosa": "synanceia_verrucosa", // Reef stonefish
        "pterois volitans": "pterois_volitans", // Common lionfish
        "caranx ignobilis": "caranx_ignobilis", // Giant trevally
        "gymnothorax javanicus": "gymnothorax_javanicus", // Giant moray
        "balistoides viridescens": "balistoides_viridescens", // Titan triggerfish
        "laticauda colubrina": "laticauda_colubrina", // Banded sea krait
        "thaumoctopus mimicus": "thaumoctopus_mimicus", // Mimic octopus
        "amphioctopus marginatus": "amphioctopus_marginatus", // Coconut octopus
        "sepia latimanus": "sepia_latimanus", // Broadclub cuttlefish
        "metasepia pfefferi": "metasepia_pfefferi", // Flamboyant cuttlefish
        "sepioteuthis lessoniana": "sepioteuthis_lessoniana", // Bigfin reef squid
        "odontodactylus scyllarus": "odontodactylus_scyllarus", // Peacock mantis shrimp
        "acanthaster planci": "acanthaster_planci", // Crown-of-thorns starfish
        "linckia laevigata": "linckia_laevigata", // Blue sea star
        "stenella longirostris": "stenella_longirostris", // Spinner dolphin
        "acropora palifera": "acropora_palifera", // Staghorn coral
        "seriatopora hystrix": "seriatopora_hystrix", // Bird's nest coral
        "heliofungia actiniformis": "heliofungia_actiniformis", // Long-tentacle plate coral
        "tubastraea coccinea": "tubastraea_coccinea", // Sun coral
        "annella spp": "annella_spp", // Sea fan
        "order scleractinia": "order_scleractinia", // Hard corals
        "abudefduf saxatilis": "abudefduf_saxatilis", // Sergeant Major
        "pseudanthias spp": "pseudanthias_spp", // Anthias
        "zebrasoma flavescens": "zebrasoma_flavescens", // Yellow Tang
        "zanclus cornutus": "zanclus_cornutus", // Moorish Idol
        "alcyonacea": "alcyonacea", // Soft Coral
        "diploria": "diploria", // Brain Coral
        "actiniaria": "actiniaria", // Sea Anemone
        "various species": "various_species", // Coral
        "abudefduf vaigiensis": "abudefduf_vaigiensis", // Indo-Pacific sergeant
        "pseudanthias squamipinnis": "pseudanthias_squamipinnis", // Lyretail anthias
        "platygyra spp": "platygyra_spp", // Brain coral
        "porites spp": "porites_spp", // Boulder coral
        "dendronephthya sp": "dendronephthya_sp", // Soft Coral
        "acropora spp": "acropora_spp", // Hard Coral
        "chaetodon semilarvatus": "chaetodon_semilarvatus", // Masked Butterflyfish
        "tursiops aduncus": "tursiops_aduncus", // Indo-Pacific bottlenose dolphin
        "stenella attenuata": "stenella_attenuata", // Pantropical spotted dolphin
        "grampus griseus": "grampus_griseus", // Risso's dolphin
        "globicephala macrorhynchus": "globicephala_macrorhynchus", // Short-finned pilot whale
        "physeter macrocephalus": "physeter_macrocephalus", // Sperm whale
        "thunnus thynnus": "thunnus_thynnus", // Bluefin Tuna
        "acanthurus leucosternon": "acanthurus_leucosternon", // Powder Blue Tang
        "hydrophis platurus": "hydrophis_platurus", // Yellow-bellied sea snake
        "crocodylus porosus": "crocodylus_porosus", // Saltwater crocodile
        "balaenoptera edeni": "balaenoptera_edeni", // Bryde's whale
        "wunderpus photogenicus": "wunderpus_photogenicus", // Wunderpus
        "hexabranchus sanguineus": "hexabranchus_sanguineus", // Spanish dancer nudibranch
        "thecacera pacifica": "thecacera_pacifica", // Pikachu nudibranch
        "hymenocera picta": "hymenocera_picta", // Harlequin shrimp
        "stenopus hispidus": "stenopus_hispidus", // Banded coral shrimp
        "lysmata amboinensis": "lysmata_amboinensis", // Skunk cleaner shrimp
        "achaeus japonicus": "achaeus_japonicus", // Orangutan crab
        "camposcia retusa": "camposcia_retusa", // Decorator crab
        "culcita novaeguineae": "culcita_novaeguineae", // Cushion star
        "ophiuroidea": "ophiuroidea", // Brittle stars
        "tripneustes gratilla": "tripneustes_gratilla", // Collector urchin
        "heterocentrotus mammillatus": "heterocentrotus_mammillatus", // Slate pencil urchin
        "toxopneustes pileolus": "toxopneustes_pileolus", // Flower urchin
        "mespilia globulus": "mespilia_globulus", // Tuxedo urchin
        "heteractis magnifica": "heteractis_magnifica", // Magnificent sea anemone
        "stichodactyla gigantea": "stichodactyla_gigantea", // Giant carpet anemone
        "cassiopea spp": "cassiopea_spp", // Upside-down jellyfish
        "ianthella basta": "ianthella_basta", // Elephant ear sponge
        "spirobranchus giganteus": "spirobranchus_giganteus", // Christmas tree worm
        "eunice aphroditois": "eunice_aphroditois", // Bobbit worm
        "clavelina moluccensis": "clavelina_moluccensis", // Bluebell tunicate
        "bugula spp": "bugula_spp", // Lace bryozoans
        "cypraea tigris": "cypraea_tigris", // Tiger cowry
        "haliclona sp": "haliclona_sp", // Vase sponge
        "sabellastarte sp": "sabellastarte_sp", // Feather-duster worm
        "dolabella auricularia": "dolabella_auricularia", // Wedge sea hare
        "holothuria scabra": "holothuria_scabra", // Sandfish sea cucumber
        "lambis lambis": "lambis_lambis", // Common spider conch
        "synapta maculata": "synapta_maculata", // Snake sea cucumber
        "gymnothorax thyrsoideus": "gymnothorax_thyrsoideus", // White-eyed moray
        "gymnothorax fimbriatus": "gymnothorax_fimbriatus", // Fimbriated moray
        "echidna nebulosa": "echidna_nebulosa", // Snowflake moray
        "gymnomuraena zebra": "gymnomuraena_zebra", // Zebra moray
        "neoglyphidodon melas": "neoglyphidodon_melas", // Black Damselfish
        "heniochus sp": "heniochus_sp", // Bannerfish
        "chaetodontidae family": "chaetodontidae_family", // Butterflyfish
        "orbicella annularis": "orbicella_annularis", // Boulder Star Coral
        "chaetodon lunula": "chaetodon_lunula", // Racoon Butterflyfish
        "heniochus intermedius": "heniochus_intermedius", // Red Sea Bannerfish
        "melichthys niger": "melichthys_niger", // Black Triggerfish
        "carassius auratus": "carassius_auratus", // Goldfish
        "cichlidae sp": "cichlidae_sp", // Cichlid
        "dascyllus aruanus": "dascyllus_aruanus", // Three-stripe Damselfish
        "chromis viridis": "chromis_viridis", // Blue Chromis
        "platax pinnatus": "platax_pinnatus", // Pinnate Spadefish
        "octopus vulgaris": "octopus_vulgaris", // Common Octopus
        "gymnothorax sp": "gymnothorax_sp", // Moray Eel
        "galeocerdo cuvier": "galeocerdo_cuvier", // Tiger Shark
        "dasyatis pastinaca": "dasyatis_pastinaca", // Common Stingray
        "rhinoptera bonasus": "rhinoptera_bonasus", // Cownose Ray
        "mola mola": "mola_mola", // Ocean Sunfish
        "nudibranchia": "nudibranchia", // Nudibranch
        "chromodoris kuniei": "chromodoris_kuniei", // Pikachu Nudibranch
        "entacmaea quadricolor": "entacmaea_quadricolor" // Bubble-tip Anemone
    ]
    
    /// Maps a scientific name to its corresponding thumbnail asset name
    /// Takes only the first two words of the scientific name as requested
    static func getThumbnailAssetName(for scientificName: String) -> String? {
        let words = scientificName.lowercased().components(separatedBy: .whitespaces)
        let prefix = words.prefix(2).joined(separator: " ")
        return scientificNameToThumbnail[prefix]
    }
    
    /// Returns a random thumbnail asset name for fallback
    static func getRandomThumbnailAssetName() -> String {
        let assetNames = Array(scientificNameToThumbnail.values)
        return assetNames.randomElement() ?? "acanthaster_planci"
    }
}
