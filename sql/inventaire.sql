CREATE TABLE IF NOT EXISTS machines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    systeme_exploitation VARCHAR(100) NOT NULL,
    ram VARCHAR(50) NOT NULL,
    espace_disque VARCHAR(50) NOT NULL,
    adresse_ip VARCHAR(45) NOT NULL,
    utilisateur_responsable VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS interventions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT NOT NULL,
    date_intervention DATE NOT NULL,
    nature VARCHAR(255) NOT NULL,
    personne_intervenue VARCHAR(100) NOT NULL,
    observations TEXT,
    FOREIGN KEY (machine_id) REFERENCES machines(id) ON DELETE CASCADE
);