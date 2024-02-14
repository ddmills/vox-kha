let project = new Project('Vox kha');
project.addAssets('Assets/**');
project.addShaders('src/shaders/**');
project.addSources('src');
resolve(project);
