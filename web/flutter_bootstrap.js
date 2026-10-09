{{flutter_js}}
{{flutter_build_config}}

// index.html의 #app 틀 안에 앱을 띄운다.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.getElementById('app'),
    });
    document.getElementById('loading')?.remove();
    await appRunner.runApp();
  },
});
