// ignore_for_file: deprecated_member_use

import 'package:carelinemed/Api/config.dart';
import 'package:carelinemed/Api/data_store.dart';
import 'package:carelinemed/controller/lab_category_controller.dart';
import 'package:carelinemed/controller_doctor/product_list_controller.dart';
import 'package:carelinemed/screen/chat/chat_screen.dart';
import 'package:carelinemed/screen/doctor_info_screen.dart';
import 'package:carelinemed/screen/lab/lab_category_screen.dart';
import 'package:carelinemed/screen/lab/lab_list_screen.dart';
import 'package:carelinemed/screen/lab/packages_screen.dart';
import 'package:carelinemed/screen/map_pages/map_screen.dart';
import 'package:carelinemed/screen/notification_screen.dart';
import 'package:carelinemed/screen/shop/product_details.dart';
import 'package:carelinemed/screen/shop/shops.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/font_family_model.dart';
import '../controller_doctor/add_doctor_detail_controller.dart';
import '../controller_doctor/home_controller.dart';
import '../utils/custom_colors.dart';
import '../widget/add_pet_bottom.dart';
import '../widget/category_tab.dart';
import 'all_categories_screen.dart';
import 'authentication/onbording_screen.dart';
import 'bottombarpro_screen.dart';
import 'category_screen.dart';
import 'home_search_screen.dart';
import 'our_product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

get picker => ImagePicker();

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectIndex = 0;
  String name = "";

  late AnimationController _fadeController;
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  late TabController tabController;

  AddPetController addPetController = Get.put(AddPetController());
  AddDoctorDetailController addDoctorDetailController = Get.put(AddDoctorDetailController());
  TextEditingController locationController = TextEditingController();
  HomeController homeController = Get.put(HomeController());
  LabCategoryController labCategoryController = Get.put(LabCategoryController());
  ProductListController productListController = Get.put(ProductListController());

  @override
  void initState() {
    super.initState();

    getCurrentLatAndLong();

    labCategoryController.labApi();

    productListController.productListApi(doctorId: "40", categoryId: "124").then((value) {
      productListController.update();
      setState(() {});
    });

    tabController = TabController(
    length: 4,
    vsync: this,
    );

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        print("Selected Tab: ${tabController.index}");

        //call API based on tab
        productListController.productListApi(
          doctorId: "40",
          categoryId: tabController.index.toString(),
        );
      }
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
    _fadeController.forward();

  }

  @override
  void dispose() {
    tabController.dispose();
    _fadeController.dispose();
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentLatAndLong() async {
    debugPrint("=================== isOnline ====================== $isOnline");
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {}
    var currentLocation = await locateUser();
    await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude).then((List<Placemark> placeMarks) {
      address = '${placeMarks.first.name!.isNotEmpty ? '${placeMarks.first.name!}, ' : ''}${placeMarks.first.thoroughfare!.isNotEmpty ? '${placeMarks.first.thoroughfare!}, ' : ''}${placeMarks.first.subLocality!.isNotEmpty ? '${placeMarks.first.subLocality!}, ' : ''}${placeMarks.first.locality!.isNotEmpty ? '${placeMarks.first.locality!}, ' : ''}${placeMarks.first.subAdministrativeArea!.isNotEmpty ? '${placeMarks.first.subAdministrativeArea!}, ' : ''}${placeMarks.first.postalCode!.isNotEmpty ? '${placeMarks.first.postalCode!}, ' : ''}${placeMarks.first.administrativeArea!.isNotEmpty ? placeMarks.first.administrativeArea : ''}';
    });
    homeController.homeApiDoctor(lat: lat.toString(), lon: long.toString());
    addDoctorDetailController.addDoctorApi();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: RefreshIndicator(
        color: primeryColor,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        onRefresh: () {
          homeController.isLoading = false;

          labCategoryController.isLoding = true;
          labCategoryController.labApi();

          setState(() {});
          return Future.delayed(
            const Duration(seconds: 2),
                () {
              setState(() {
                homeController.homeApiDoctor(lat: lat.toString(), lon: long.toString());
              });
            },
          );
        },
        child: GetBuilder<HomeController>(
          builder: (homeController) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                // 1. THE WHITE PREMIUM HEADER
                _buildSliverHeader(),

                //the TabBar
                _tabBar(tabController),

                // 2. MAIN CONTENT BODY
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),

                        // 2.5 QUICK ACTIONS GRID
                        _buildAnimatedSection(
                          delay: 0,
                          child: _buildQuickActionsGrid(),
                        ),
                        const SizedBox(height: 15),

                        // 3. CONSULT TOP DOCTORS
                        _buildAnimatedSection(
                          delay: 50,
                          child: _buildBannerSection(homeController),
                        ),
                        const SizedBox(height: 15),

                        // 4. OUR SERVICES
                        _buildAnimatedSection(
                          delay: 100,
                          child: _buildServicesSection(homeController),
                        ),
                        const SizedBox(height: 30),

                        // 5. MY NEAREST DOCTOR
                        _buildAnimatedSection(
                          delay: 200,
                          child: _buildNearestDoctorSection(),
                        ),
                        const SizedBox(height: 30),

                        // 6. SURGEON BANNER
                        _buildAnimatedSection(
                          delay: 300,
                          child: _buildSurgeonBanner(),
                        ),
                        const SizedBox(height: 30),

                        // 7. LAB SECTION
                        _buildAnimatedSection(
                          delay: 400,
                          child: _buildLabSection(homeController),
                        ),
                        const SizedBox(height: 20),

                        // 8. PHARMACY PRODUCTS
                        _buildAnimatedSection(
                          delay: 500,
                          child: _buildPharmacySection(),
                        ),
                        const SizedBox(height: 20),

                        // 9. PATIENTS
                        _buildAnimatedSection(
                          delay: 600,
                          child: _buildPatientsSection(homeController),
                        ),
                        const SizedBox(height: 30),

                        // 10. FAVORITES
                        if (homeController.isLoading && homeController.homeModel!.favDoctorList!.isNotEmpty)
                          _buildAnimatedSection(
                            delay: 700,
                            child: _buildFavoritesSection(homeController),
                          ),

                        // 11. DYNAMIC LISTS
                        if (homeController.isLoading)
                          _buildDynamicSections(homeController),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    double begin = (delay / 1000).clamp(0.0, 0.99);
    double end = ((delay + 400) / 1000).clamp(0.01, 1.0);
    if (begin >= end) {
      begin = end - 0.01;
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _contentAnimation,
          curve: Interval(
            begin,
            end,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentAnimation,
            curve: Interval(
              begin,
              end,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  // 1. HEADER
  Widget _buildSliverHeader() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _headerAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(_headerAnimation),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 50, 15, 15),
            decoration: const BoxDecoration(
              color: Color(0xFF2BAE9E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///LOCATION
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        (address != null && address.isNotEmpty) ? address : "address",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // PROFILE + LOGO + GRID MENU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ScaleTransition(
                      scale: _headerAnimation,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: getData.read("UserLogin") == null
                            ? const Icon(Icons.person, color: Colors.grey, size: 30)
                            : ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/ezgif.com-crop.gif",
                                  image: "${Config.imageBaseurlDoctor}${getData.read("UserLogin")["image"]}",
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/logo/img-removebg.png",
                          height: 60,
                          width: 180,
                        ),
                      ),
                    ),

                    ScaleTransition(
                      scale: _headerAnimation,
                      child: PopupMenuButton<int>(
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white,
                        elevation: 2,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.grid_view_rounded, color: primeryColor, size: 26),
                        ),
                        onSelected: (value) {
                          if (value == 1) {
                            if (getData.read("UserLogin") == null) {
                              Get.offAll(BoardingPage());
                            } else {
                              Get.to(ChatScreen());
                            }
                          } else if (value == 2) {
                            Get.to(NotificationScreen());
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, color: primeryColor, size: 22),
                                const SizedBox(width: 12),
                                const Text("Chats", style: TextStyle(fontFamily: 'Gilroy', color: Colors.black)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(Icons.notifications_none_rounded, color: primeryColor, size: 22),
                                const SizedBox(width: 12),
                                const Text("Notifications", style: TextStyle(fontFamily: 'Gilroy', color: Colors.black)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // SEARCH BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(const HomeSearchScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1.3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Search Medicines, Brands & Wellness",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        //navigate to cart page..
                      },
                      child: const Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _tabBar(TabController tabController) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: _StickyTabBarDelegate(
      child: Material(
        color: const Color(0xFFF8F9FD),
        child: Center(
          child: Container(
            height: 105,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              
              onTap: (index) {
                if (index == 3) {
                  Get.to(() => const OurProduct());
                }
              },
              
              tabs: [
                CategoryTab(icon: Icons.grid_view, title: "All", index: 0, controller: tabController),
                CategoryTab(icon: Icons.receipt, title: "Prescription", index: 1, controller: tabController),
                CategoryTab(icon: Icons.favorite, title: "Healthcamp", index: 2, controller: tabController),
                CategoryTab(icon: Icons.local_mall_outlined, title: "Our Product", index: 3, controller: tabController),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildQuickActionsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: "Upload Prescription\n& Order",
                  icon: Icons.camera_alt_outlined,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionCard(
                  title: "Order Medicines",
                  subtitle: "(Fast Delivery)",
                  icon: Icons.medication,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: "Book\nLab Tests",
                  icon: Icons.science_outlined,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickActionCard(
                  title: "Consult\nDoctors Online",
                  icon: Icons.medical_services_outlined,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: FontFamily.gilroyBold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: FontFamily.gilroyMedium,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: primeryColor, size: 28),
          ],
        ),
      ),
    );
  }

  // Keep all other widget methods EXACTLY the same but wrap banner items with animation
  Widget _buildBannerSection(HomeController homeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Consult with Top Doctors", style: AppDesign.headingLarge),
        ),
        const SizedBox(height: 15),
        homeController.isLoading
            ? homeController.homeModel!.bannerData!.isNotEmpty
            ? CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 2.4,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            autoPlay: homeController.homeModel!.bannerData!.length > 1,
            onPageChanged: (index, reason) => setState(() => selectIndex = index),
          ),
          items: homeController.homeModel!.bannerData!.map((item) {
            return GestureDetector(
              onTap: () {
                Get.to(CategoryScreen(
                  departmentId: item.department.toString(),
                  name: "${item.departmentName}",
                  image: "${Config.imageBaseurlDoctor}${item.image}",
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage("${Config.imageBaseurlDoctor}${item.image}"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.title != null)
                        Text(
                          "${item.title}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      if (item.subTitle != null)
                        Text(
                          "${item.subTitle}",
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )
            : const SizedBox()
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerSkeleton(height: 150),
        ),
      ],
    );
  }

  // ALL OTHER METHODS REMAIN EXACTLY THE SAME - Just copy from original
  Widget _buildServicesSection(HomeController homeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Our Services", style: AppDesign.headingLarge),
              GestureDetector(
                onTap: () {
                  Get.to(() => const AllCategoriesScreen());
                },
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: primeryColor,
                    fontFamily: FontFamily.gilroyBold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        homeController.isLoading
            ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int index = 0; index < homeController.homeModel!.departmentList!.length; index++)
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        CategoryScreen(
                          departmentId: "${homeController.homeModel!.departmentList![index].id}",
                          name: "${homeController.homeModel!.departmentList![index].name}",
                          image: "${Config.imageBaseurlDoctor}${homeController.homeModel!.departmentList![index].image}",
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 65,
                          width: 65,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F6FA),
                            shape: BoxShape.circle,
                          ),
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/ezgif.com-crop.gif",
                            image: "${Config.imageBaseurlDoctor}${homeController.homeModel!.departmentList![index].image}",
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            "${homeController.homeModel!.departmentList![index].name}",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.2
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: List.generate(4, (index) => Padding(padding: EdgeInsets.only(right: 20), child: ShimmerSkeleton(height: 65, width: 65, borderRadius: BorderRadius.circular(32.5))))),
        )
      ],
    );
  }

  Widget _buildNearestDoctorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Get.to(const MapScreen());
        },
        child: Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2F5B).withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 5),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF8F9FD),
                  ),
                ),
              ),

              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  width: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primeryColor,
                        accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      bottomLeft: Radius.circular(28),
                      topRight: Radius.circular(80),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0, top: 0, bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                  ),
                  child: Image.asset(
                    "assets/doc1.png",
                    width: 170,
                    height: 190,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("assets/doctor_dummy.png", width: 170, height: 190, fit: BoxFit.cover);
                    },
                  ),
                ),
              ),

              Positioned(
                left: 185, top: 30, right: 20, bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4, width: 25,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    Text(
                      "FIND YOUR BEST",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        fontSize: 11,
                        letterSpacing: 1.0,
                        color: const Color(0xFF6F767E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "NEAREST\nDOCTOR",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyExtraBold,
                        fontSize: 24,
                        height: 1.05,
                        color: primeryColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primeryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "At Minimum Costs",
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 11,
                          color: primeryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        height: 28, width: 30,
                        decoration: BoxDecoration(
                          color: primeryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F2F5B).withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurgeonBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Get.to(const HomeSearchScreen());
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primeryColor.withOpacity(0.08),
                accentColor.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: primeryColor.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Book appointment with",
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 15,
                            letterSpacing: 0.3,
                            color: primeryColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Expert Surgeons",
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyExtraBold,
                            fontSize: 22,
                            color: primeryColor,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: primeryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primeryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                  )
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildBodyPartIcon(Icons.remove_red_eye_rounded, "Eye"),
                      const SizedBox(width: 20),
                      _buildBodyPartIcon(Icons.favorite_rounded, "Heart"),
                      const SizedBox(width: 20),
                      _buildBodyPartIcon(Icons.accessibility_new_rounded, "Ortho"),
                      const SizedBox(width: 20),
                      _buildBodyPartIcon(Icons.face_rounded, "Skin"),
                      const SizedBox(width: 20),
                      _buildBodyPartIcon(Icons.grid_view_rounded, "More"),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabSection(HomeController homeController) {
    return GetBuilder<LabCategoryController>(
        builder: (labController) {
          if (labController.isLoding ||
              labController.labCategoryApiModel == null ||
              labController.labCategoryApiModel!.categoryList!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerSkeleton(height: 280, borderRadius: BorderRadius.circular(20)),
            );
          }

          var labs = labController.labCategoryApiModel!.categoryList!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Popular Lab Centers", style: AppDesign.headingLarge),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const LabCategoryScreen());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primeryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text("See All", style: TextStyle(color: primeryColor, fontFamily: FontFamily.gilroyBold, fontSize: 13)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, color: primeryColor, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              _buildMarketingBannerWithLabs(labs),
            ],
          );
        }
    );
  }

  Widget _buildMarketingBannerWithLabs(List<dynamic> labs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accentColor.withOpacity(0.1), primeryColor.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: primeryColor.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 6)),
          ],
          border: Border.all(color: primeryColor.withOpacity(0.15), width: 1.5),
        ),
        child: Stack(
          children: [
            Positioned(top: -50, right: -30, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: primeryColor.withOpacity(0.04)))),
            Positioned(bottom: -20, left: -20, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withOpacity(0.06)))),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primeryColor, accentColor],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: primeryColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: primeryColor, borderRadius: BorderRadius.circular(8)),
                              child: Text("SPECIAL OFFER", style: TextStyle(fontFamily: FontFamily.gilroyBold, fontSize: 10, color: Colors.white, letterSpacing: 0.5)),
                            ),
                            const SizedBox(height: 6),
                            Text("Home Sample Collection", style: TextStyle(fontFamily: FontFamily.gilroyExtraBold, fontSize: 18, color: const Color(0xFF0F2F5B), height: 1.2)),
                            const SizedBox(height: 2),
                            Text("Certified Labs • No Extra Fees", style: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 13, color: primeryColor.withOpacity(0.8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var item in labs)
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: _buildPremiumLabCard(item),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLabCard(var item) {
    return GestureDetector(
      onTap: () {
        Get.to(LabListScreen(
          categoryId: "${item.id}",
          category: "${item.name}",
        ));
      },
      child: Container(
        width: 132,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4E342E).withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: const Color(0xFFF5F7FA),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/ezgif.com-crop.gif",
                  image: "${Config.imageBaseurlDoctor}${item.image}",
                  fit: BoxFit.cover,
                  imageErrorBuilder: (c, o, s) => Center(child: Icon(Icons.science_rounded, size: 40, color: primeryColor.withOpacity(0.3))),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.name}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesign.headingSmall.copyWith(fontSize: 13, height: 1.2),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: primeryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text("Certified", style: TextStyle(fontFamily: FontFamily.gilroyBold, fontSize: 9, color: primeryColor)),
                      ),
                      const Icon(Icons.arrow_circle_right_rounded, color: Color(0xFF00A89F), size: 20)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacySection() {
    return GetBuilder<ProductListController>(
        builder: (prodController) {

          if (prodController.productListModel == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pharmacy Essentials", style: AppDesign.headingLarge),
                  const SizedBox(height: 15),
                  ShimmerSkeleton(height: 230, borderRadius: BorderRadius.circular(20)),
                ],
              ),
            );
          }

          if (prodController.productListModel!.productList == null ||
              prodController.productListModel!.productList!.isEmpty) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pharmacy Essentials", style: AppDesign.headingLarge),
                    GestureDetector(
                        onTap: () {
                          Get.to(() => const ShopsScreen());
                        },
                        child: Text("See All", style: TextStyle(color: primeryColor, fontFamily: FontFamily.gilroyBold))
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var product in prodController.productListModel!.productList!)
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: _buildPremiumProductCard(
                          id: "${product.id}",
                          name: "${product.productName}",
                          image: "${product.productImage}",
                          price: product.priceDetail!.isNotEmpty ? "${product.priceDetail!.first.price}" : "0",
                          basePrice: product.priceDetail!.isNotEmpty ? "${product.priceDetail!.first.basePrice}" : "0",
                          category: "Surgical",
                        ),
                      ),
                  ],
                ),
              )
            ],
          );
        }
    );
  }

  Widget _buildPremiumProductCard({
    required String id,
    required String name,
    required String image,
    required String price,
    required String basePrice,
    required String category,
  }) {
    Color tagColor = Colors.blueGrey;
    if (category.toLowerCase().contains("surgical")) tagColor = Colors.blue;
    if (category.toLowerCase().contains("vitamin")) tagColor = Colors.orange;

    return GestureDetector(
      onTap: () {
        Get.to(ProductDetails(
          title: "Pharmacy",
          sitterId: "40",
          productIndex: 0,
          prodId: id,
        ));
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppDesign.shadowSoft,
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/ezgif.com-crop.gif",
                      image: "${Config.imageBaseurlDoctor}$image",
                      fit: BoxFit.contain,
                      imageErrorBuilder: (c, o, s) => Center(child: Icon(Icons.broken_image, color: Colors.grey[300])),
                    ),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3)],
                    ),
                    child: Text(category, style: TextStyle(fontSize: 9, fontFamily: FontFamily.gilroyBold, color: tagColor)),
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),

            Text(
              name,
              style: AppDesign.headingSmall.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (double.tryParse(basePrice) != null && double.tryParse(price) != null && double.parse(basePrice) > double.parse(price))
                      Text(
                        "\$$basePrice",
                        style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11, fontFamily: FontFamily.gilroyMedium),
                      ),
                    Text(
                      "\$$price",
                      style: TextStyle(color: const Color(0xFF0F2F5B), fontWeight: FontWeight.w900, fontSize: 16, fontFamily: FontFamily.gilroyExtraBold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2F5B),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F2F5B).withOpacity(0.15), blurRadius: 6, offset: Offset(0, 3))],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsSection(HomeController homeController) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Patients".tr, style: AppDesign.headingLarge.copyWith(fontSize: 20)),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (getData.read("UserLogin") == null) {
                      Get.offAll(BoardingPage());
                    } else {
                      addPetController.addPetBottom(context).then((value) {
                        homeController.homeApiDoctor(lat: lat.toString(), lon: long.toString());
                      });
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 65, width: 65,
                        decoration: BoxDecoration(color: primeryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.add, color: primeryColor, size: 30),
                      ),
                      const SizedBox(height: 8),
                      Text("Add New", style: TextStyle(fontFamily: FontFamily.gilroyBold, fontSize: 12))
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                if (homeController.homeModel?.familyMember != null)
                  for (var member in homeController.homeModel!.familyMember!)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onTap: () {
                          addPetController.addPetBottom(
                              context,
                              familyMemberId: member.id.toString()
                          ).then((value) {
                            homeController.homeApiDoctor(lat: lat.toString(), lon: long.toString());
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 65, width: 65,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: AppDesign.shadowSoft
                              ),
                              child: ClipOval(
                                child: FadeInImage.assetNetwork(
                                    height: 65, width: 65, fit: BoxFit.cover,
                                    placeholder: "assets/ezgif.com-crop.gif",
                                    image: "${Config.imageBaseurlDoctor}${member.profileImage}"
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(member.name ?? "", style: TextStyle(fontFamily: FontFamily.gilroyBold, fontSize: 12))
                          ],
                        ),
                      ),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(HomeController homeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Favorite Doctors", style: AppDesign.headingLarge),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: homeController.homeModel!.favDoctorList!.map((doc) =>
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    width: 120,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FadeInImage.assetNetwork(
                              height: 120, width: 120, fit: BoxFit.cover,
                              placeholder: "assets/ezgif.com-crop.gif",
                              image: "${Config.imageBaseurlDoctor}${doc.logo}"
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(doc.title ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: AppDesign.labelMedium)
                      ],
                    ),
                  )
              ).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDynamicSections(HomeController homeController) {
    return ListView.separated(
      itemCount: homeController.homeModel!.dynamicList!.length,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final section = homeController.homeModel!.dynamicList![index];
        if (section.module == "Doctor") return const SizedBox();

        return SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${section.title}",
                style: AppDesign.headingLarge.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppDesign.space16),
              if (section.module == "Hospital")
                _buildDoctorHospitalList(section)
              else if (section.module == "Lab")
                _buildLabList(section),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppDesign.space32),
    );
  }

  Widget _buildDoctorHospitalList(dynamic section) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < section.details!.length; i++) ...[
            _buildDoctorCard(
              name: "${section.details![i].name}",
              image: "${Config.imageBaseurlDoctor}${section.details![i].logo}",
              rating: "${section.details![i].avgStar}",
              reviews: "${section.details![i].totReview}",
              type: section.module == "Hospital" ? "Hospital" : "Specialist",
              onTap: () {
                Get.to(
                  DoctorInfoScreen(
                    doctorid: "${section.details![i].id}",
                    departmentId: "${section.details![i].departmentId}",
                  ),
                );
              },
            ),
            if (i != section.details!.length - 1) const SizedBox(width: AppDesign.space12),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String image,
    required String rating,
    required String reviews,
    required String type,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      onTap: onTap,
      width: 280,
      radius: AppDesign.radiusMedium,
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
              child: FadeInImage.assetNetwork(
                placeholder: "assets/ezgif.com-crop.gif",
                image: image,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppDesign.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: AppDesign.headingSmall.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDesign.space4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[600], size: 16),
                    const SizedBox(width: AppDesign.space4),
                    Text(rating, style: AppDesign.captionBold.copyWith(fontSize: 13)),
                    Text(
                      " ($reviews)",
                      style: AppDesign.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppDesign.space8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primeryColor.withOpacity(0.12),
                        primeryColor.withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: AppDesign.labelSmall.copyWith(color: primeryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabList(dynamic section) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < section.details!.length; i++) ...[
            _buildLabCard(
              name: "${section.details![i].name}",
              image: "${Config.imageBaseurlDoctor}${section.details![i].logo}",
              address: "${section.details![i].address}",
              rating: "${section.details![i].avgStar}",
              reviews: "${section.details![i].totReview}",
              distance: "${section.details![i].distance}",
              onTap: () {
                Get.to(
                  PackagesScreen(
                    categoryId: "${section.category}",
                    labId: "${section.details![i].id}",
                    title: "${section.details![i].name}",
                  ),
                );
              },
            ),
            if (i != section.details!.length - 1) const SizedBox(width: AppDesign.space12),
          ],
        ],
      ),
    );
  }

  Widget _buildLabCard({
    required String name,
    required String image,
    required String address,
    required String rating,
    required String reviews,
    required String distance,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      onTap: onTap,
      width: Get.width * 0.8,
      child: Row(
        children: [
          Container(
            height: 80,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
              child: FadeInImage.assetNetwork(
                height: 80,
                width: 70,
                fit: BoxFit.cover,
                placeholder: "assets/ezgif.com-crop.gif",
                placeholderFit: BoxFit.cover,
                image: image,
              ),
            ),
          ),
          const SizedBox(width: AppDesign.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppDesign.headingSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDesign.space4),
                Text(
                  address,
                  style: AppDesign.caption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: AppDesign.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber[600], size: 16),
                        const SizedBox(width: 4),
                        Text(reviews, style: AppDesign.captionBold.copyWith(fontSize: 13)),
                        Text(
                          " ($rating)",
                          style: AppDesign.caption,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppDesign.textTertiary,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "$distance KM",
                          style: AppDesign.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBodyPartIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A154B).withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: primeryColor, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 13,
            color: primeryColor.withOpacity(0.8),
          ),
        )
      ],
    );
  }
}

// ALL DESIGN SYSTEM CLASSES REMAIN EXACTLY THE SAME

class AppDesign {
  AppDesign._();

  static const Color backgroundPage = Color(0xFFF8F9FD);
  static const Color surfaceCard = Colors.white;
  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6F767E);
  static const Color textTertiary = Color(0xFF9A9FA5);
  static final Color borderMedium = Colors.black.withOpacity(0.08);

  static const TextStyle headingLarge = TextStyle(
    fontFamily: FontFamily.gilroyExtraBold,
    fontSize: 20,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: FontFamily.gilroyBold,
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: FontFamily.gilroyBold,
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: FontFamily.gilroyMedium,
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: FontFamily.gilroyMedium,
    fontSize: 11,
    color: textSecondary,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: FontFamily.gilroyBold,
    fontSize: 11,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: FontFamily.gilroyBold,
    fontSize: 13,
    letterSpacing: 0.2,
    color: textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: FontFamily.gilroyBold,
    fontSize: 11,
    letterSpacing: 0.3,
    color: textPrimary,
  );

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveSnappy = Curves.easeOutCubic;

  static final List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 8,
      offset: const Offset(0, 2),
    )
  ];

  static final List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 6),
    )
  ];

  static final List<BoxShadow> shadowDeep = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 24,
      offset: const Offset(0, 8),
    )
  ];

  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool hasBorder;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  const PremiumCard({super.key, required this.child, this.onTap, this.width, this.height, this.hasBorder = false, this.radius, this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width, height: height,
        padding: padding,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius ?? 12),
            border: hasBorder ? Border.all(color: primeryColor) : null,
            boxShadow: AppDesign.shadowSoft
        ),
        child: child,
      ),
    );
  }
}

class PremiumIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const PremiumIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40, width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: primeryColor, size: 22),
      ),
    );
  }
}

class GradientIconContainer extends StatelessWidget {
  final Widget child;
  final double size;
  final Color primaryColor;

  const GradientIconContainer({super.key, required this.child, required this.size, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size, width: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withOpacity(0.1)
      ),
      child: Center(child: child),
    );
  }
}

class SectionContainer extends StatelessWidget {
  final Widget child;
  const SectionContainer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: child);
  }
}

class ShimmerSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  const ShimmerSkeleton({super.key, required this.height, this.width, this.borderRadius});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: borderRadius ?? BorderRadius.circular(12)),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 90.0;

  @override
  double get maxExtent => 90.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return true;
  }
}
