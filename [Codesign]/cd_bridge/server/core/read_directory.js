const fs = require('fs');
const path = require('path');

function readDirectory(dir_path, extensions) {
    const dir = path.parse(dir_path).dir;
    const files = fs.readdirSync(dir);
    if(files && files.length > 0){
        
        const filteredFiles = files.filter(file => {
            return extensions.some(ext => file.toLowerCase().endsWith(ext.toLowerCase()));
        });

        for(let i = 0; i < filteredFiles.length; i++) {
            filteredFiles[i] = path.join(dir, filteredFiles[i]);
        }
        return filteredFiles;
    } else return [];

}

function readNUIDirectory(dir_path, resource_path, extensions){
    // const dir = path.parse(dir_path).dir;
    const files = fs.readdirSync(dir_path);
    if(files && files.length > 0){
        
        const filteredFiles = files.filter(file => {
            return extensions.some(ext => file.toLowerCase().endsWith(ext.toLowerCase()));
        });

        for(let i = 0; i < filteredFiles.length; i++) {
            filteredFiles[i] = resource_path + filteredFiles[i];
        }
        return filteredFiles;
    } else return [];
}

global.exports('ReadDirectory', readDirectory);
global.exports('ReadNUIDirectory', readNUIDirectory);