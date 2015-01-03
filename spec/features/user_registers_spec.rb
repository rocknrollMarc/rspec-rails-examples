require 'rails_helper'

feature "User registers", :type => :feature do

  scenario "with valid details" do

    visit "/"

    click_link "Sign up"
    expect(current_path).to eq(new_user_registration_path)

    fill_in "Email", with: "tester@example.tld"
    fill_in "Password", with: "test-password"
    fill_in "Password confirmation", with: "test-password"
    click_button "Sign up"

    expect(current_path).to eq "/"
    expect(page).to have_content(
      "A message with a confirmation link has been sent to your email address.
      Please follow the link to activate your account."
    )

    open_email "tester@example.tld", with_subject: "Confirmation instructions"
    visit_in_email "Confirm my account"

    expect(current_path).to eq new_user_session_path
    expect(page).to have_content "Your email address has been successfully confirmed."

    fill_in "Email", with: "tester@example.tld"
    fill_in "Password", with: "test-password"
    click_button "Log in"

    expect(current_path).to eq "/"
    expect(page).to have_content "Signed in successfully."
    expect(page).to have_content "Hello, tester@example.tld"
  end


  context "with invalid details" do

    before do
      visit new_user_registration_path
    end

    scenario "blank fields" do

      expect_fields_to_be_blank

      click_button "Sign up"

      within "#error_explanation" do
        expect(page).to have_content "2 errors prohibited this user from being saved"
        expect(page).to have_selector "li", text: "Email can't be blank"
        expect(page).to have_selector "li", text: "Password can't be blank"
      end
    end

    scenario "incorrect password confirmation" do

      fill_in "Email", with: "tester@example.tld"
      fill_in "Password", with: "test-password"
      fill_in "Password confirmation", with: "not-test-password"
      click_button "Sign up"

      within "#error_explanation" do
        expect(page).to have_content "1 error prohibited this user from being saved"
        expect(page).to have_selector "li", text: "Password confirmation doesn't match Password"
      end
    end

    xscenario "already registered email" do

    end

    xscenario "invalid email" do

    end

    xscenario "too short password" do

    end

  end

  private

  def expect_fields_to_be_blank
    expect(page).to have_field("Email", with: "", type: "email")
    # These password fields don't have value attributes in the generated HTML,
    # so with: syntax doesn't work.
    expect(find_field("Password", type: "password").value).to be_nil
    expect(find_field("Password confirmation", type: "password").value).to be_nil
  end

end