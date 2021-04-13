<?php

namespace Drupal\bd_core\Plugin\Block;

use Drupal\Core\Block\BlockBase;

/**
 * Provides a 'AjaxViewBlock' block.
 *
 * @Block(
 *  id = "ajax_view_block",
 *  admin_label = @Translation("Members AJAX Display"),
 *  category = @Translation("Carapace"),
 * )
 */
class AjaxViewBlock extends BlockBase {

  /**
   * {@inheritdoc}
   */
  public function build() {

    $build = [];

    $build['ajax_view_block'] = [
      '#theme' => 'collection_ajax',
      '#attached' => ['library' => 'bd_core/mystic_behaviors']
    ];

    return $build;
  }

}

