<?php

/**
 * @file
 * The BD profile.
 */

use Drupal\Core\Extension\Dependency;
use Drupal\Core\Extension\Extension;
use Drupal\Core\Form\FormState;
use Drupal\Core\Installer\InstallerKernel;
use Drupal\user\RoleInterface;

/**
 * Implements hook_install_tasks().
 */
function bd_install_tasks() {
  $tasks = [];

  $tasks['bd_grant_shortcut_access'] = [];
  $tasks['bd_set_default_theme'] = [];
  $tasks['bd_finish_install'] = [
    'display_name' => t('After install tasks')
  ];

  return $tasks;
}

/**
 * Finish BD installation process.
 *
 * @param array $install_state
 *   The install state.
 *
 */

function bd_finish_install(array &$install_state) {
  // Try to install optional configs
  \Drupal::service('config.installer')->installOptionalConfig();

  // Assign user 1 the "administrator" role.
  $user = \Drupal\user\Entity\User::load(1);
  $user->addRole('administrator');
  $user->save();

}

/**
 * Implements hook_modules_installed().
 */
function bd_modules_installed($modules) {
  if (!InstallerKernel::installationAttempted() && !Drupal::isConfigSyncing()) {
    /** @var \Drupal\Core\Extension\ModuleExtensionList $moduleExtensionList */
    $moduleExtensionList = \Drupal::service('extension.list.module');
    $thunder_features = array_filter($moduleExtensionList->getList(), function (Extension $module) {
      return $module->info['package'] === 'BD Optional';
    });

    foreach ($thunder_features as $id => $extension) {

      $dependencies = array_map(function ($dependency) {
        return Dependency::createFromString($dependency)->getName();
      }, $extension->info['dependencies']);

      if (!in_array($id, $modules) && !empty(array_intersect($modules, $dependencies))) {
        \Drupal::messenger()->addWarning(t('To get the full Thunder experience, we recommend to install the @module module. See all supported optional modules at <a href="/admin/modules/extend-thunder">Thunder Optional modules</a>.', ['@module' => $extension->info['name']]));
      }
    }
  }
}



/**
 * Allows authenticated users to use shortcuts.
 */
function bd_grant_shortcut_access() {
  if (Drupal::moduleHandler()->moduleExists('shortcut')) {
    user_role_grant_permissions(RoleInterface::AUTHENTICATED_ID, ['access shortcuts']);
  }
}

/**
 * Sets the default and administration themes.
 */
function bd_set_default_theme() {
  Drupal::configFactory()
    ->getEditable('system.theme')
    ->set('default', 'bd_client_theme')
    ->set('admin', 'adminimal_theme')
    ->save(TRUE);

  // Use the admin theme for creating content.
  if (Drupal::moduleHandler()->moduleExists('node')) {
    Drupal::configFactory()
      ->getEditable('node.settings')
      ->set('use_admin_theme', TRUE)
      ->save(TRUE);
  }
}

function bd_form_install_configure_form_alter(&$form, FormState $form_state) {
  // Add a value as example that one can choose an arbitrary site name.
  $form['site_information']['site_name']['#placeholder'] = t('Born-Digital\'s Collections');
}



/**
 * Implements hook_install().
 */
function bd_install($is_syncing) {
  // First, do everything in standard profile.
  include_once DRUPAL_ROOT . '/core/profiles/standard/standard.install';
  standard_install();
}
