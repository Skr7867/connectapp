import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../res/color/app_colors.dart';
import '../../res/listitem/list_item.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildEmailRow(String label, String email, context) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontFamily: AppFonts.opensansRegular,
          ),
        ),
        InkWell(
          onTap: () => _launchEmail(email),
          child: Text(
            email,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontFamily: AppFonts.opensansRegular,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'contact_us'.tr,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        // height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: 'About ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    fontFamily: AppFonts.opensansRegular,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Connect',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueColor),
                    ),
                  ],
                ),
              ),
              Text(
                "CONNECT is more than just a platform—it's a digital ecosystem designed to transform how we interact, learn, and grow in the digital age.",
                style: TextStyle(
                    fontFamily: AppFonts.opensansRegular,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Founded in 2023, our mission is to create a space where learning meets community, where technology enhances human connection rather than replacing it, and where every interaction adds value to your digital experience.",
                style: TextStyle(
                  fontFamily: AppFonts.opensansRegular,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2970&q=80',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Our Values',
                style: TextStyle(fontSize: 30, color: AppColors.blueColor),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: contactTitle.length,
                itemBuilder: (context, int index) {
                  return Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.greyColor.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor:
                                quickAccessColor[index].withOpacity(0.3),
                            foregroundColor:
                                Theme.of(context).textTheme.bodyLarge?.color,
                            child: contacticons[index],
                          ),
                          Text(
                            contactTitle[index],
                            style: TextStyle(
                                fontSize: 25,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                          Text(
                            contactSubTitle[index],
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Text(
                'Our Teams',
                style: TextStyle(fontSize: 30, color: AppColors.blueColor),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: teamTitle.length,
                itemBuilder: (context, int index) {
                  return Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.greyColor.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, left: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: quickAccessColor[index], width: 2),
                            ),
                            child: Image.network(
                              teamsImage[index],
                              height: 70,
                            ),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            teamTitle[index],
                            style: TextStyle(
                                fontSize: 25,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            teamPositions[index],
                            style: TextStyle(
                                color: quickAccessColor[index],
                                fontFamily: AppFonts.opensansRegular),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            teamDescription[index],
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontFamily: AppFonts.opensansRegular),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Text(
                'Contact Us',
                style: TextStyle(fontSize: 30, color: AppColors.blueColor),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(bottom: 50),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.home,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      title: Text(
                        'Headquarters',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        "Foxx – Verein zur Förderung einer zukunftsorientierten Lebenskultur Canavalstraße 7/143 5020 Salzburg Austria",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      title: Text(
                        'Email Us',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          _buildEmailRow("General Inquiries",
                              "info@connectapp.cc", context),
                          _buildEmailRow(
                              "Support", "support@connectapp.cc", context),
                          _buildEmailRow(
                              "Press", "press@connectapp.cc", context),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.card_travel,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      title: Text(
                        'Careers',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  'Interested in joining our team? Check Out Our',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                            TextSpan(
                              text: ' careers page',
                              style: const TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchUrl(
                                    'https://yourwebsite.com/careers'),
                            ),
                            TextSpan(
                              text: ' or email us at ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                            TextSpan(
                              text: 'careers@connectapp.cc',
                              style: const TextStyle(
                                fontFamily: AppFonts.opensansRegular,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    _launchUrl('mailto:careers@connectapp.cc'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
