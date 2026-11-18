import Flutter
import MapKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AxisAppleMap") {
      registrar.register(AxisAppleMapFactory(messenger: registrar.messenger()), withId: "axis/apple_map")
    }
  }
}

// MARK: - Apple 지도(라이트 + muted) 플랫폼 뷰

/// Flutter의 MapCanvas가 iOS에서 띄우는 MKMapView. 일정 핀·동선을 그리고 핀을 누르면 Flutter로 알려 준다.
final class AxisAppleMapFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    AxisAppleMap(frame: frame, viewId: viewId, args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

final class AxisPin: NSObject, MKAnnotation {
  let id: String
  let label: String
  let isHome: Bool
  var blue: Bool
  @objc dynamic var coordinate: CLLocationCoordinate2D

  init(id: String, label: String, isHome: Bool, blue: Bool, coordinate: CLLocationCoordinate2D) {
    self.id = id
    self.label = label
    self.isHome = isHome
    self.blue = blue
    self.coordinate = coordinate
  }
}

final class AxisAppleMap: NSObject, FlutterPlatformView, MKMapViewDelegate {
  private let map: MKMapView
  private let channel: FlutterMethodChannel
  private var routeWidth: CGFloat = 3
  private var fitted = false
  private var padding = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
  private var removedLine: MKPolyline?

  private static let brand = UIColor(red: 0, green: 0x4F / 255.0, blue: 0xED / 255.0, alpha: 1)
  private static let ink = UIColor(red: 0x1F / 255.0, green: 0x20 / 255.0, blue: 0x27 / 255.0, alpha: 1)
  private static let gray = UIColor(red: 0xA3 / 255.0, green: 0xAA / 255.0, blue: 0xB5 / 255.0, alpha: 1)

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    map = MKMapView(frame: frame)
    channel = FlutterMethodChannel(name: "axis/apple_map_\(viewId)", binaryMessenger: messenger)
    super.init()
    map.overrideUserInterfaceStyle = .light
    if #available(iOS 16.0, *) {
      map.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .muted)
    } else {
      map.mapType = .mutedStandard
    }
    map.pointOfInterestFilter = .excludingAll
    map.showsCompass = false
    map.isRotateEnabled = false
    map.isPitchEnabled = false
    map.delegate = self
    map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "update", let a = call.arguments as? [String: Any] {
        self?.apply(a)
      }
      result(nil)
    }
    apply(args)
  }

  func view() -> UIView { map }

  private func coords(_ raw: Any?) -> [CLLocationCoordinate2D] {
    guard let list = raw as? [[Double]] else { return [] }
    return list.compactMap { $0.count == 2 ? CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) : nil }
  }

  private func apply(_ a: [String: Any]) {
    if let w = a["routeWidth"] as? Double { routeWidth = CGFloat(w) }
    if let p = a["padding"] as? [Double], p.count == 4 {
      padding = UIEdgeInsets(top: p[0], left: p[1], bottom: p[2], right: p[3])
    }
    map.removeOverlays(map.overlays)
    map.removeAnnotations(map.annotations)
    let removed = coords(a["removed"])
    if removed.count > 1 {
      let line = MKPolyline(coordinates: removed, count: removed.count)
      removedLine = line
      map.addOverlay(line)
    } else {
      removedLine = nil
    }
    let route = coords(a["route"])
    if route.count > 1 { map.addOverlay(MKPolyline(coordinates: route, count: route.count)) }
    var all: [CLLocationCoordinate2D] = []
    for case let pin as [String: Any] in (a["pins"] as? [Any] ?? []) {
      guard let id = pin["id"] as? String, let lat = pin["lat"] as? Double, let lng = pin["lng"] as? Double else { continue }
      let c = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      all.append(c)
      map.addAnnotation(
        AxisPin(id: id, label: pin["label"] as? String ?? "", isHome: pin["home"] as? Bool ?? false,
                blue: pin["blue"] as? Bool ?? false, coordinate: c))
    }
    if !fitted, !all.isEmpty {
      fitted = true
      var rect = MKMapRect.null
      for c in all {
        let p = MKMapPoint(c)
        rect = rect.union(MKMapRect(x: p.x, y: p.y, width: 0.1, height: 0.1))
      }
      map.setVisibleMapRect(rect, edgePadding: padding, animated: false)
    }
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let line = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
    let r = MKPolylineRenderer(polyline: line)
    if line === removedLine {
      r.strokeColor = Self.gray
      r.lineWidth = 2
      r.lineDashPattern = [5, 4]
    } else {
      r.strokeColor = Self.brand
      r.lineWidth = routeWidth
      r.lineCap = .round
      r.lineJoin = .round
    }
    return r
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let pin = annotation as? AxisPin else { return nil }
    let v = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation)
    v.canShowCallout = false
    v.image = Self.pinImage(pin)
    v.centerOffset = .zero
    v.displayPriority = .required
    v.zPriority = pin.blue ? .max : (pin.isHome ? .defaultSelected : .defaultUnselected)
    return v
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let pin = view.annotation as? AxisPin {
      channel.invokeMethod("pinTap", arguments: pin.id)
    }
    mapView.deselectAnnotation(view.annotation, animated: false)
  }

  /// 피그마 핀: 20 원. 번호 핀은 검정(선택 시 파랑 + 흰 테두리 + 빛), 집은 흰 원 + 검정 테두리 + 집 모양.
  private static func pinImage(_ pin: AxisPin) -> UIImage {
    let glow: CGFloat = pin.blue ? 10 : 2
    let size = CGSize(width: 20 + glow * 2, height: 20 + glow * 2)
    return UIGraphicsImageRenderer(size: size).image { ctx in
      let c = ctx.cgContext
      let circle = CGRect(x: glow, y: glow, width: 20, height: 20)
      if pin.blue {
        c.setShadow(offset: .zero, blur: 10, color: brand.withAlphaComponent(0.8).cgColor)
      } else {
        c.setShadow(offset: CGSize(width: 0, height: 1), blur: 2, color: UIColor.black.withAlphaComponent(0.25).cgColor)
      }
      if pin.isHome {
        UIColor.white.setFill()
        c.fillEllipse(in: circle)
        c.setShadow(offset: .zero, blur: 0, color: nil)
        ink.setStroke()
        c.setLineWidth(1)
        c.strokeEllipse(in: circle.insetBy(dx: 0.5, dy: 0.5))
        let cfg = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
        if let house = UIImage(systemName: "house.fill", withConfiguration: cfg)?.withTintColor(ink, renderingMode: .alwaysOriginal) {
          let s = house.size
          house.draw(in: CGRect(x: circle.midX - s.width / 2, y: circle.midY - s.height / 2, width: s.width, height: s.height))
        }
        return
      }
      (pin.blue ? brand : ink).setFill()
      c.fillEllipse(in: circle)
      c.setShadow(offset: .zero, blur: 0, color: nil)
      if pin.blue {
        UIColor.white.setStroke()
        c.setLineWidth(1.5)
        c.strokeEllipse(in: circle.insetBy(dx: 0.75, dy: 0.75))
      }
      let text = NSAttributedString(
        string: pin.label,
        attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.white])
      let ts = text.size()
      text.draw(at: CGPoint(x: circle.midX - ts.width / 2, y: circle.midY - ts.height / 2))
    }
  }
}
