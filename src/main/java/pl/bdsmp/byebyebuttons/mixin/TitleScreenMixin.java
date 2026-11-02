package pl.bdsmp.byebyebuttons.mixin;

import net.minecraft.client.gui.components.ImageButton;
import net.minecraft.client.gui.screens.TitleScreen;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(TitleScreen.class)
public abstract class TitleScreenMixin {
    @Inject(method = "init", at = @At("TAIL"))
    private void bdsmp$removeExtraTitleIcons(CallbackInfo ci) {
        // Vanilla's Language and Accessibility controls are image-only widgets.
        // Removing them after init also catches widgets added by title-screen layouts.
        ((ScreenAccessor) this).bdsmp$getChildren()
                .removeIf(widget -> widget instanceof ImageButton);
    }
}
