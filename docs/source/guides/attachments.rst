Attachments guide
=================
Attachments on horses are handled by a bunch of different system spread across multiple modules and classes. The system currently allows you to associate an :lua:alias:`HorseMod.AttachmentSlot` to an `attachment point <https://pzwiki.net/wiki/Attachment_(scripts)>`_ on the horse model and define slots various items can occupy with different caracteristics defined as :lua:class:`HorseMod.AttachmentDefinition`.

Creating a new slot
-------------------
Slots require the use of :lua:class:`HorseMod.SlotDefinition` to associated a slot name to a model attachment point on the horse model. You can also use multiple times the same attachment point if needed. Alternatively, extra properties can be set to have the attachment be a mane attachment. 

Defining a new attachment
-------------------------
Defining a whole new attachment depends on the function :lua:obj:`HorseMod.AttachmentData.addNewAttachments`. This function allows you to add new slot and item definitions to an existing item full type or create a new item definition entry.

Below is an example usage:
::

  local AttachmentData = require("HorseMod/attachments/AttachmentData")
  local attachmentDef = {
      unequipBehavior = {
          time = -1,
          anim = {
              ["Left"] = "EquipMyItem_Left",
              ["Right"] = "EquipMyItem_Right",
          },
          shouldHold = true,
      },
      model = "MyMod.MyItemModel", -- has variants with riding state suffixes
  }
  AttachmentData.addNewAttachment("MyMod.MyItemFullType", "Reins", attachmentDef)

.. note:: Attachments should be added from the shared folder so that both the server and client are aware of them.

AttachmentsLoad
---------------
The file `server/HorseMod/AttachmentsLoad.lua` is used to load slot definitions in :lua:obj:`HorseMod.attachments.AttachmentData.SLOTS_DEFINITION` and generate the various tables used by the attachment system from :lua:class:`HorseMod.SlotDefinition` entries:

* :lua:obj:`HorseMod.attachments.AttachmentData.SLOTS`
* :lua:obj:`HorseMod.attachments.AttachmentData.MANE_SLOTS_SET`
* :lua:obj:`HorseMod.attachments.AttachmentData.CONTAINER_ITEMS`

It will also verify that the provided attachments are of the right format and log errors if not:

* Checks that every slot definition has a :lua:obj:`HorseMod.SlotDefinition.modelAttachment` point defined.
* Creates the apparel location in the ``Animal`` attached locations group for every slot defined.
* If an attachment definition has a :lua:class:`HorseMod.ContainerBehavior`, it checks that the item actually is a container (``ItemType.CONTAINER``). It also verifies that the :lua:obj:`HorseMod.ContainerBehavior.worldItem` invisible container has the same capacity as the accessory item.
* Removes any :lua:class:`HorseMod.ItemDefinition` entry from :lua:obj:`HorseMod.attachments.AttachmentData.items` that don't contain any attachment definitions.
