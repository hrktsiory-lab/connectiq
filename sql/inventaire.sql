-- Structure de la table machines
CREATE TABLE IF NOT EXISTS machines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    systeme_exploitation VARCHAR(100) NOT NULL,
    ram VARCHAR(50) NOT NULL,
    espace_disque VARCHAR(50) NOT NULL,
    adresse_ip VARCHAR(45) NOT NULL,
    utilisateur_responsable VARCHAR(100) NOT NULL
);

-- Structure de la table interventions
CREATE TABLE IF NOT EXISTS interventions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT NOT NULL,
    date_intervention DATE NOT NULL,
    nature VARCHAR(255) NOT NULL,
    personne_intervenue VARCHAR(100) NOT NULL,
    observations TEXT,
    FOREIGN KEY (machine_id) REFERENCES machines(id) ON DELETE CASCADE
);

-- Données de départ
INSERT INTO machines (id, nom, systeme_exploitation, ram, espace_disque, adresse_ip, utilisateur_responsable)
VALUES (1, 'PC-Francisco', 'Windows 10 Pro', '16 Go', '512 Go SSD', '192.168.3.43', 'Francisco')
ON DUPLICATE KEY UPDATE nom=VALUES(nom);